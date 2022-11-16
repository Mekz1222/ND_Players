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
        const action = $(this).data("action");

        if (action == "new") {
            $(".overlay").fadeOut("fast");
            $("#creationForm").fadeIn("fast");
            return;
        };

        $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({
            action: action
        }));
    });

    $(".creationCancel").click(function() {
        $(".overlay").fadeIn("fast");
        $("#creationForm").fadeOut("fast");
    });

    $("#creationForm").submit(function() {
        $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({
            action: "new",
            firstName: $("#characterFN"),
            lastName: $("#characterLN"),
            dob: $("#characterDOB"),
            gender: $("#characterGender")
        }));
        $("#characterFN, #characterLN, #characterDOB, #characterGender").val("")
        return false;
    });
});