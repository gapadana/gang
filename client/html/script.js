window.addEventListener("message", function (event) {
	if (event.data.action == "display") {
		$(".content").css("display", "flex")
	}else if(event.data.action == "change") {
		$(".body").text(event.data.body)
		$(".description").text(event.data.desc)
	}else if(event.data.action == "hide") {
		$(".content").css("display", "none")
	}
});