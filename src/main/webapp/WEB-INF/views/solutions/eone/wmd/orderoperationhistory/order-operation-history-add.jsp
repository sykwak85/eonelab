<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.studio3s.co.kr/tags" prefix="s" %>
<script>
$(function(){

	window.OrderOperationHistoryAdd = (function($){
		var init = function(){
			_setForm();
			_bindEvent();
		}
		, _bindEvent = function(){
			$(".btn-cancel").click(function() {
				Dialog.cancel();
			});
			$(".btn-add").click(function() {
				_addOrderOperationHistory();
			});
		}
		, _setForm = function(){

		}
		, _addOrderOperationHistory = function(){
			var $contents = $(".contents-wrap");
			if($contents.validate()){
				SfpAjax.ajax("<c:url value='/solutions/eone/wmd/orderoperationhistory/add'/>", $contents.find("select, input, textarea").serialize(), function(data) {
					alert("저장에 성공하였습니다.");
					Dialog.close(true);
				});
			}
		};
		init();
	})(jQuery);
});
</script>
<style></style>

<main>
	<header>
		<h2><s:interpret word='지시별 동작 히스토리 등록' abbr='' /></h2>
	</header>

	<div class="contents-wrap">
		<section>
			<div class="register-table">
				<p class="required"><s:interpret word='필수항목' abbr='' /></p>
				<ul>
					<li>
						<div class="title"><s:interpret word='지시번호' abbr='' /><em>*</em></div>
						<div class="cont">
							<div class="line-wrap">
								<span><input type="text" name="orderId" placeholder="<s:interpret word='지시번호' abbr='' />" data-valid-max-size='30' data-required="true"  /></span>
							</div>
						</div>
					</li>
					<li>
						<div class="title"><s:interpret word='시스템동작모드ID' abbr='' /><em>*</em></div>
						<div class="cont">
							<div class="line-wrap">
								<span><input type="text" name="systemOperationModeId" placeholder="<s:interpret word='시스템동작모드ID' abbr='' />" data-valid-max-size='30' data-required="true"  /></span>
							</div>
						</div>
					</li>
					<li>
						<div class="title"><s:interpret word='시스템동작모드단계ID' abbr='' /><em>*</em></div>
						<div class="cont">
							<div class="line-wrap">
								<span><input type="text" name="systemOperationModeStepId" placeholder="<s:interpret word='시스템동작모드단계ID' abbr='' />" data-valid-max-size='30' data-required="true"  /></span>
							</div>
						</div>
					</li>
					<li>
						<div class="title"><s:interpret word='시스템동작모드단계순서' abbr='' /></div>
						<div class="cont">
							<div class="line-wrap">
								<span><input type="text" name="systemOperationModeStepSort" placeholder="<s:interpret word='시스템동작모드단계순서' abbr='' />" data-valid-min='' data-valid-max=''  data-valid="number" /></span>
							</div>
						</div>
					</li>
					<li>
						<div class="title"><s:interpret word='시작일시' abbr='' /><em>*</em></div>
						<div class="cont">
							<div class="line-wrap">
								<span><input type="text" name="operationStartDt" placeholder="<s:interpret word='시작일시' abbr='' />" data-valid-max-size='23' data-required="true"  /></span>
							</div>
						</div>
					</li>
					<li>
						<div class="title"><s:interpret word='완료일시' abbr='' /></div>
						<div class="cont">
							<div class="line-wrap">
								<span><input type="text" name="operationEndDt" placeholder="<s:interpret word='완료일시' abbr='' />" data-valid-max-size='23'   /></span>
							</div>
						</div>
					</li>
				</ul>
			</div>
		</section>
		<footer>
			<div class="align-center">
				<button class="btn-cancel"><s:interpret word='닫기' abbr='' /></button>
				<button class="btn-add blue"><s:interpret word='등록' abbr='' /></button>
			</div>
		</footer>
	</div>
</main>