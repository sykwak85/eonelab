<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.studio3s.co.kr/tags" prefix="s" %>
<script>
$(function(){

	window.SystemOperationModeStepList = (function($){
		var init = function(){
			$("#system-operation-mode-step-grid").grid({
				header:[
					[
						{name : "<s:interpret word='시스템동작모드ID' abbr='' />"},
						{name : "<s:interpret word='시스템동작모드단계ID' abbr='' />"},
						{name : "<s:interpret word='시스템동작모드단계명' abbr='' />"},
						{name : "<s:interpret word='시스템동작모드단계순서' abbr='' />"},
						{name : "<s:interpret word='시스템동작모드단계설명' abbr='' />"},
						{name : "<s:interpret word='병행처리여부' abbr='' />"},
						{name : "<s:interpret word='삭제여부' abbr='' />"},
						{name : "<s:interpret word='작업' abbr='' />", width : "120px"}
					]
				]
				, addClasses : "small"
			});
			$(".footer-wrap").pager({"click" : list});
			_setForm();
			_bindEvent();
		}
		, _setForm = function(){

		}
		, _bindEvent = function(){
			$(".btn-srch").click(function() {
				list();
			});
			$("#system-operation-mode-step-grid").on("click", ".btn-mod", function() {
				Dialog.open("<c:url value='/solutions/eone/wmd/systemoperationmodestep/system-operation-mode-step-modify.dialog' />",750, $("#system-operation-mode-step-grid").grid("getData", this), function(){
					list();
				});
			});
			$(".btn-add").click(function() {
				Dialog.open("<c:url value='/solutions/eone/wmd/systemoperationmodestep/system-operation-mode-step-add.dialog' />",750, null, function(){
					list();
				});
			});
			$(".btn-del").click(function() {
				deleteList();
			});
		}
		, list = function(paging){
			SfpAjax.ajax("<c:url value='/solutions/eone/wmd/systemoperationmodestep/getPagingList'/>",
				$.extend($(".function-area").find("select, input").serializeObject(), paging)
				, function(data) {
					$("#system-operation-mode-step-grid").grid("draw", data.list, function(row){

					});
					$(".footer-wrap").pager("setPage", data.paging);
			});
		}
		, deleteList = function(){
			var paramList = [];
			$("#system-operation-mode-step-grid input[type='checkbox']:checked").each(function(){
				paramList[paramList.length] = { systemOperationModeId : $("#system-operation-mode-step-grid").grid("getData", this).systemOperationModeId};
			});
			SfpAjax.ajax("<c:url value='/solutions/eone/wmd/systemoperationmodestep/deleteList'/>", paramList, function(data) {
				alert("삭제에 성공하였습니다.");
				list();
			});
		};
		init();
		return {
			list : list
		}
	})(jQuery);
});

</script>
<style></style>

<main>
	<header>
		<h2><s:interpret word='시스템 동작 모드 단계' abbr='' /></h2>
	</header>

	<div class="contents-wrap">
		<section>
			<div class="function-area">
				<div class="align-left">
					<span>
						<label class="label-text"><s:interpret word='시스템동작모드ID' abbr='' /></label>
						<input type="text" name="systemOperationModeId" placeholder="<s:interpret word='시스템동작모드ID' abbr='' />">
					</span>
					<span>
						<label class="label-text"><s:interpret word='시스템동작모드단계ID' abbr='' /></label>
						<input type="text" name="systemOperationModeStepId" placeholder="<s:interpret word='시스템동작모드단계ID' abbr='' />">
					</span>
					<span>
						<label class="label-text"><s:interpret word='시스템동작모드단계명' abbr='' /></label>
						<input type="text" name="systemOperationModeStepName" placeholder="<s:interpret word='시스템동작모드단계명' abbr='' />">
					</span>
					<span>
						<label class="label-text"><s:interpret word='시스템동작모드단계순서' abbr='' /></label>
						<input type="text" name="systemOperationModeStepSort" placeholder="<s:interpret word='시스템동작모드단계순서' abbr='' />">
					</span>
					<span>
						<label class="label-text"><s:interpret word='시스템동작모드단계설명' abbr='' /></label>
						<input type="text" name="systemOperationModeStepDesc" placeholder="<s:interpret word='시스템동작모드단계설명' abbr='' />">
					</span>
					<span>
						<label class="label-text"><s:interpret word='병행처리여부' abbr='' /></label>
						<input type="text" name="parallelProcessYn" placeholder="<s:interpret word='병행처리여부' abbr='' />">
					</span>
					<button class="btn-srch ico"><s:interpret word='조회' abbr='' /></button>
					<button class="btn-reset image"><s:interpret word='초기화' abbr='' /></button>
				</div>
				<div class="align-center"></div>
				<div class="align-right">
					<button class="btn-add ico"><s:interpret word='등록' abbr='' /></button>
				</div>
			</div>
			<div id="system-operation-mode-step-grid"></div>
		</section>
		<footer>
			<div class="footer-wrap"></div>
		</footer>
	</div>
</main>

<script type="text/sfp-template" data-model="system-operation-mode-step-grid">
<tr>
	<td>@{systemOperationModeId}</td>
	<td>@{systemOperationModeStepId}</td>
	<td>@{systemOperationModeStepName}</td>
	<td>@{systemOperationModeStepSort}</td>
	<td>@{systemOperationModeStepDesc}</td>
	<td>@{parallelProcessYn}</td>
	<td name="delYn" data-grid-checked="true"></td>
	<td><button type="button" class="btn-mod"><s:interpret word='수정' abbr='' /></button></td>
</tr>
</script>
