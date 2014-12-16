import de.bezier.data.sql.*;
import de.bezier.guido.*;


PostgreSQL pgsql;
// ArrayList<Shot> shots;
PShape court;
HexGrid grid;
int[] gridSize = {25, 21};
float radius;
int size_scale = 2;
Hexagon selectedHex = null;
HexDetails details;
Canvas courtCanvas;
Canvas detailCanvas;
Canvas selectionCanvas;
Controller controller;
Selection selectionUI;


void setup() {
    size(1330, 700, P2D);
    Interactive.make(this);
    courtCanvas = new Canvas(0, 0, 1000, 700);
    detailCanvas = new Canvas(1000, 550, 330, 150);
    selectionCanvas = new Canvas(1000, 0, 330, 550);
    radius = courtCanvas.w/((gridSize[0] -1 )*sqrt(3));
    grid = new HexGrid(gridSize, radius, courtCanvas);
    initController();
    selectionUI = new Selection(selectionCanvas, controller);
    controller.applaySelection();
    court = loadShape("img/NBA_ready.svg");
    grid.hexShape.fill(200);
    details = new HexDetails(10.0);
    details.set_canvas(detailCanvas);
}

void initController() {
    String user     = "nba";
    String pass     = "hexhex";
    String database = "NBAdb";
    pgsql = new PostgreSQL( this, "localhost", database, user, pass );
    controller = new Controller(pgsql, grid);
    grid.setController(controller);
}


void draw() {
    background(255);
    grid.display();
    shape(court, 0, 0, courtCanvas.w, courtCanvas.w*28/50);
    detailCanvas.drawRect(220);
    details.display();
    selectionCanvas.drawRect(250);
    selectionUI.display();
}

void mouseMoved() {
    if (mouseX < 1000) {
        try {
            Hexagon newHex = grid.get_hexagon_fromXY(mouseX, mouseY);
            if (newHex != selectedHex) {
                if (selectedHex != null) {
                    selectedHex.set_selected(false);
                }
                selectedHex = newHex;
                selectedHex.set_selected(true);
                details.set_newHex(newHex);
            }
        } catch (ArrayIndexOutOfBoundsException e) {
            // selectedHex.set_selected(false);
            selectedHex = null;
            details.set_newHex(null);
        }
    }
}