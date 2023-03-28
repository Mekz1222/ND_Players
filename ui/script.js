let selected = 0;

const $overlay = $('.overlay');
const $lineup = $('.lineup');

window.addEventListener("message", function(event) {
    const item = event.data;

    if (item.type === "display") {
        $overlay.fadeIn(item.status ? "fast" : "fast");
    }

    if (item.type === "lineup") {
        $lineup.empty();

        for (let i = 1; i < item.amount + 1; i++) {
            $lineup.append(`<div id="lineup${i}" class="lineupCharacter" data-lineup="${i}"></div>`);
        }

        $(".lineupCharacter").click(function() {
            selected = $(this).data("lineup");
            $.post(`https://${GetParentResourceName()}/select`, JSON.stringify({
                lineup: selected
            }));
        });
    }
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

    $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({ action }), function() {})
    .fail(function(error) {
        console.error(error);
    });
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

    $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({ action: "delete" }), function() {
        $(`#lineup${selected}`).hide();
    })
    .fail(function(error) {
        console.error(error);
    });
});

// confirm character creator
$("#creationForm").submit(function(event) {
    event.preventDefault();

    const firstName = $("#characterFN").val();
    const lastName = $("#characterLN").val();
    const dob = $("#characterDOB").val();
    const gender = $("#characterGender").val();

    $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({ action: "new", firstName, lastName, dob, gender }), function() {
        $("#characterFN, #characterLN, #characterDOB, #characterGender").val("");
    })
    .fail(function(error) {
        console.error(error);
    });
});