package com.s3s.solutions.eone.manager;

import java.lang.reflect.Field;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

import com.ghgande.j2mod.modbus.facade.ModbusTCPMaster;
import com.ghgande.j2mod.modbus.procimg.Register;
import com.s3s.sfp.dmw.DMWManager;
import com.s3s.sfp.dmw.handler.ModbusTCPHandler;
import com.s3s.solutions.eone.EoneConst;
import com.s3s.solutions.eone.define.EOrderType;
import com.s3s.solutions.eone.define.ERack;
import com.s3s.solutions.eone.dmw.command.PLCCommand;
import com.s3s.solutions.eone.dmw.command.message.body.AlarmRequestBody;
import com.s3s.solutions.eone.dmw.command.message.body.OrderReportBody;
import com.s3s.solutions.eone.dmw.command.message.body.OrderRequestBody;
import com.s3s.solutions.eone.service.wmd.order.OrderVO;
import com.s3s.solutions.eone.service.wmd.ordermanagerhistory.OrderManagerHistoryService;
import com.s3s.solutions.eone.service.wmd.ordermanagerhistory.dto.OrderManagerHistoryDTO;
import com.s3s.solutions.eone.service.wmd.orderwork.OrderWorkVO;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RequiredArgsConstructor
@Service
public class PLCManager {

	private final DMWManager dmwManager;
	private final OrderManagerHistoryService orderManagerHistoryService;

	private final int INPUT_REQUEST = 2;
//	private final String BUFFER_REQUEST = "1";
	private final int OUTPUT_REQUEST = 1;
	private final int READY_STATUS = 0;
	private final int COMPLETE_STATUS = 1;
	private final int ALARM_STATUS = 1;

	private final String CMD_ORDER = "order";
	private final String CMD_ALARM = "alarm";

	private final String CMD_WAIT_ORDER = "waitOrder";

	private final int WAIT_ORDER_ADDR = 217;
	//dmw_convert_property테이블의 system_device_type값을 alarm property_type = alarmStatus 기준정보 설정 필요
	private final int ALM_ADDR = 112;
	private final int ALM_ADDR1 = 674;
	private final int ALM_ADDR2= 1074;

	private final String  ALARM = "alarmStatus1";
	
	private final String ORDER_PROC_BUFFER_RACK = "orderProcBufferRack";
	private final String ORDER_PROC_BUFFERX = "orderProcBufferX";
	private final String ORDER_PROC_BUFFERY = "orderProcBufferY";

	public boolean sendPlc(OrderVO dbOrder, List<OrderWorkVO> workList, boolean isInterfaceFinishOrder) throws Exception{
		//오더를 가져온다.
		OrderReportBody plcOrder = PLCCommand.getOrder(dbOrder.getLineNo());

		//오더가 있고 해당 오더와 보내는 오더가 같을 경우에는
		if(plcOrder != null && StringUtils.equals(String.valueOf(plcOrder.getOrderNo()), dbOrder.getOrderId())) {
			return false;
		}

		OrderRequestBody sendOrder = new OrderRequestBody();

		sendOrder.setOrderNo1(Long.valueOf(dbOrder.getOrderId()));
		sendOrder.setOrderNo2(Long.valueOf(dbOrder.getOrderId()));
		sendOrder.setOrderType(Integer.parseInt(EOrderType.valueOf(dbOrder.getOrderTypeCd()).getCode()));

		//알람처리
		if(isInterfaceFinishOrder) {
			sendOrder.setInterfacePlanGroupFinish(1);
		}

		makeWorkData(workList, sendOrder);
	
		AtomicBoolean result = new AtomicBoolean(false);
		dmwManager.getHadler(dbOrder.getLineNo(), ModbusTCPHandler.class).ifPresent(o -> {
			try {
				orderManagerHistoryService.add(new OrderManagerHistoryDTO() {{
					setReq(dbOrder.getLineNo()+" line "+ sendOrder.toString());
				}});
				o.send(CMD_ORDER, sendOrder);
				result.set(true);
			} catch (Exception e) {
				e.printStackTrace();
				result.set(false);
			}
		});
		return result.get();
	}

	/*
	 * PLC에서 완료 처리를 받은 후 WRITE 영역에 order를 받았다는 처리.
	 */
	public void sendFinishOrder() throws Exception {
		dmwManager.getHadler(EoneConst.PLC_ID, ModbusTCPHandler.class).ifPresent(o -> {
			try {
				o.send(CMD_WAIT_ORDER, WAIT_ORDER_ADDR, 1);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		});
	}

	/*
	 * PLC에서 완료 처리를 받은 후 WRITE 영역에 order를 받았다는 처리.
	 */
	public void sendWaitOrder() throws Exception {
		dmwManager.getHadler(EoneConst.PLC_ID, ModbusTCPHandler.class).ifPresent(o -> {
			try {
				o.send(CMD_WAIT_ORDER, WAIT_ORDER_ADDR, 0);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		});

	}
	
	/*
	 * TrayId 중복 체크 후 결과를 알람 Status WRITE 영역에 처리
	 * 라인을 기준으로 해당영역에 맞는 PLC Address를 찾아 Alarm Status를 쓰게 함. 
	 */
	public void sendAlarmState(String lineNo) throws Exception {
		//int value = Integer.parseInt(alarmState);
		
		AlarmRequestBody alarmRequest = new AlarmRequestBody(); 
	    dmwManager.getHadler(EoneConst.PLC_ID, ModbusTCPHandler.class).ifPresent(o -> {
	        try {
//	        	PLC 인터페이스시 시간설정
//	        	orderManagerHistoryService.add(new OrderManagerHistoryDTO() {{
//					setReq(dbOrder.getLineNo()+" line "+ sendOrder.toString());
//				}});
//				o.send(CMD_ALARM, alarmRequest);
	        	
	        	switch(lineNo) {
		        	case "L1": o.send(CMD_ALARM, ALM_ADDR, 1); break;
		        	case "L2": o.send(CMD_ALARM, ALM_ADDR, 1); break;
		        	case "L3": o.send(CMD_ALARM, ALM_ADDR, 1); break;
	        	}
	        	log.info("Sending ALARM signal to address {}, value=1", ALM_ADDR);
	        	//라인기준으로 분기처리하는 로직 추가.
	        	//PLC Address 기준정보 데이터 추가 필요.
	        	//PLC주소명 W112, 실제 번지수(10진수) 112, 실제 번지수(16진수)  0x0070
	        	//PLC주소명 W2A2, 실제 번지수(10진수) 674, 실제 번지수(16진수)  0x02A2
	        	//PLC주소명 W432, 실제 번지수(10진수) 1074, 실제 번지수(16진수) 0x0432
	            // W112 주소에 값 전송(1라인)
	            //o.send(ALARM, ALM_ADDR, 1);
	            //alarmRequest.setAlarmStatus1(1);

	            // W2A2 주소에 값 전송(2라인)
	            //o.send(ALARM, ALM_ADDR1, 1);
	            //alarmRequest.setAlarmStatus2(1);

	            // W432 주소에 값 전송(3라인)
	            //o.send(ALARM, ALM_ADDR2, 1);
	            //alarmRequest.setAlarmStatus3(1);
	            
	        } catch (Exception e) {
	            log.error("Error sending alarm state to PLC", e);
	            e.printStackTrace();
	        }
	    });
	}
	

	//FIXME 렉번호 좌우로 변경해야함
	private void makeWorkData(List<OrderWorkVO> workList, OrderRequestBody sendOrder) {
		for(OrderWorkVO work : workList) {
			refSet(sendOrder, String.format("%s%s", ORDER_PROC_BUFFER_RACK, work.getBufferId()), Integer.parseInt(ERack.valueOf(work.getRackId()).getCode()));
			refSet(sendOrder, String.format("%s%s", ORDER_PROC_BUFFERX, work.getBufferId()), Integer.parseInt(String.valueOf(work.getRackCellXAxis())));
			refSet(sendOrder, String.format("%s%s", ORDER_PROC_BUFFERY, work.getBufferId()), Integer.parseInt(String.valueOf(work.getRackCellYAxis())));
		}
	}

	/**
	 * Desc : 넘겨받은 문자열(fieldName)에 해당 되는 변수에 값(filedvalue)을 -> Object(VO)에 넣기
	 */
	@SuppressWarnings("rawtypes")
	public void refSet(Object object, String fieldName, Object fieldValue) {
		Class cls = object.getClass();
		try {
			Field field = cls.getDeclaredField(fieldName);
			field.setAccessible(true);
			field.set(object, fieldValue);
		} catch (Exception e) {
			throw new IllegalStateException(e);
		}
	}
	
	
}
