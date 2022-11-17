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

        if (item.type == "lineup") {
            $(".lineup").empty();
            for (let i = 1; i < item.amount+1; i++) {
                $(".lineup").append(`<div id="lineup${i}" class="lineupCharacter" data-lineup="${i}"></div>`);
            };
            $(".lineupCharacter").click(function() {
                $.post(`https://${GetParentResourceName()}/select`, JSON.stringify({
                    lineup: $(this).data("lineup")
                }));
                $(this).hide();
            });
        };
    });

    // interaction buttons at the bottom, can be left, right, new, delete.
    $(".interactionButton").click(function() {
        const action = $(this).data("action");

        if (action == "new") {
            $(".overlay").fadeOut("fast");
            $("#creationForm").fadeIn("fast");
            return;
        } else if (action == "delete") {
            $(".overlay").fadeOut("fast");
            $(".confirmDelete").fadeIn("fast");
            return;
        };

        $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({
            action: action
        }));
    });

    // cancel character creator
    $(".creationCancel").click(function() {
        $(".overlay").fadeIn("fast");
        $("#creationForm").fadeOut("fast");
    });

    // cancel character delete
    $(".cancelDeleteBtn").click(function() {
        $(".overlay").fadeIn("fast");
        $(".confirmDelete").fadeOut("fast");
    });

    // confirm character delete
    $(".confirmDeleteBtn").click(function() {
        $(".overlay").fadeIn("fast");
        $(".confirmDelete").fadeOut("fast");
        $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({
            action: "delete"
        }));
    });

    // confirm character creator
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