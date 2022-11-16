$(function() {
    window.addEventListener("message", function(event) {
        const item = event.data;
        if (item.type == "display") {
            if (item.status) {
                $(".overlay").fadeIn("fast");
            } else {
                $(".overlay").fadeOut("fast");
            };
        };
    });

    $(".interactionButton").click(function() {
        $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({
            action: $(this).data("action")
        }));
    });
});