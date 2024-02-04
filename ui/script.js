let selected = 0;

const $overlay = $(".overlay");
const $lineup = $(".lineup");

// map center of the 8092x8092 px map not image center but gta map center.
const mapCenterX = 3755;
const mapCenterY = 5525;

// size of the map image.
const mapWidth = 8192;
const mapHeight = 8192;

// variable to keep track of the previously clicked marker.
let previousMarker = null;
let previousChoice = null;

// adds current selected marker data.
const selectedMarker = {}

// function to handle the marker click event.
function handleMarkerClick(marker, choice) {
    selectedMarker.id = marker.data("id");
    selectedMarker.type = marker.data("type");
    selectedMarker.image = marker.data("image");
    $(".map-spawn > div > img").attr("src", `../data/images/${selectedMarker.image}`);
    $(".map-spawn").fadeIn();

    if (previousMarker) {
        previousMarker.removeClass("marker-active");
    }
    if (previousChoice) {
        previousChoice.removeClass("choice-active");
    }

    marker.addClass("marker-active");
    previousMarker = marker;

    choice.addClass("choice-active");
    previousChoice = choice;
}

$(".map-spawn-button").click(function() {
    $.post(`https://${GetParentResourceName()}/spawn`, JSON.stringify({
        id: selectedMarker.id,
        type: selectedMarker.type
    }));
})

// remove selected location when anything else than pin markers or menu button is clicked.
$(document).click(function(event) {
    if ($(".map-display").css("display") == "none") {return}

    const target = $(event.target)
    if (!target.is(".marker") && !target.is(".map-choices > div.choice-active")) {
        $(".marker").removeClass("marker-active");
        $(".map-choices > div").removeClass("choice-active");
        $(".map-spawn").fadeOut();
    }
});

window.addEventListener("message", function(event) {
    const item = event.data;

    if (item.type === "selector") {
        if (item.status) {
            $overlay.fadeIn("fast");
        } else {
            $overlay.fadeOut("fast");
            $lineup.hide();
            setTimeout(() => {
                $(".map-display").fadeOut();
            }, 1500);
        }
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

    if (item.type === "map") {
        if (item.status) {
            $(".overlay").hide();
            $(".map-display").fadeIn("fast");

            // size of the image on the ui.
            const htmlMapWidth = $(".map-container > img").width();
            const htmlMapHeight = $(".map-container > img").height();

            // calculate the center of the final map showing.
            const centerX = ((mapCenterX / (mapWidth/100)) / 100) * htmlMapWidth;
            const centerY = ((mapCenterY / (mapHeight/100)) / 100) * htmlMapHeight;

            // add markers for the in game locations.
            const markers = item.markers
            if (markers.DEFAULT) {
                for (let marker in markers.DEFAULT) {
                
                    const locationX = centerX + ((markers.DEFAULT[marker].coords.x / (12400/100)) / 100) * htmlMapWidth;
                    const locationY = centerY - ((markers.DEFAULT[marker].coords.y / (12400/100)) / 100) * htmlMapHeight;
    
                    const markerElement = $(`<div data-id="${marker}" data-type="DEFAULT" data-image="${markers.DEFAULT[marker].image}" class="marker" style="left: ${locationX}px; top: ${locationY}px;"></div>`);
                    const choice = $(`<div>${markers.DEFAULT[marker].name}</div>`)
    
                    $(".map-markers").append(markerElement);
                    $(".map-choices").append(choice)
    
                    markerElement.click(function() {
                        handleMarkerClick($(this), choice)
                    });
                    choice.click(function() {
                        handleMarkerClick(markerElement, choice)
                    });
                }
            }
            if (markers[item.job]) {
                for (let marker in markers[item.job]) {
                
                    const locationX = centerX + ((markers[item.job][marker].coords.x / (12400/100)) / 100) * htmlMapWidth;
                    const locationY = centerY - ((markers[item.job][marker].coords.y / (12400/100)) / 100) * htmlMapHeight;
    
                    const markerElement = $(`<div data-id="${marker}" data-type="${item.job}" data-image="${markers[item.job][marker].image}" class="marker" style="left: ${locationX}px; top: ${locationY}px;"></div>`);
                    const choice = $(`<div>${markers[item.job][marker].name}</div>`)

                    $(".map-markers").append(markerElement);
                    $(".map-choices").append(choice)
    
                    markerElement.click(function() {
                        handleMarkerClick($(this), choice)
                    });
                    choice.click(function() {
                        handleMarkerClick(markerElement, choice)
                    });
                }
            }
        } else {
            $(".map-display").fadeOut("fast");
        }
    }
});

// interaction buttons at the bottom, can be left, right, new, delete.
$(".interactionButton").click(function() {
    const action = $(this).data("action");
    $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({
        action: action
    }));
});
