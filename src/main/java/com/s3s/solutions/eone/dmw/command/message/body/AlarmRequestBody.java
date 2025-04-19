package com.s3s.solutions.eone.dmw.command.message.body;

import lombok.Getter;
import lombok.Setter;

//알람발생 PLC VO
@Setter
@Getter
public class AlarmRequestBody extends DefaultBodyVO {
	
	private Integer alarmStatus1 = 0;
	private Integer alarmStatus2 = 0;
	private Integer alarmStatus3 = 0;
}