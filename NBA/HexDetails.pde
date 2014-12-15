public class HexDetails  {
	Hexagon currentHex = null;
	Canvas canvas;
	PShape  hexShape;

	public HexDetails (float r) {
		this.hexShape = createHex(2*r);
	}

	void set_newHex(Hexagon newHex) {
		this.currentHex = newHex;
	}

	void set_canvas(Canvas can) {
		this.canvas = can;
	}

	void display() {
		if (currentHex != null) {
			pushMatrix();
			translate(currentHex.center[0], currentHex.center[1]);
			fill(0, 0, 255);
			shape(this.hexShape);
			popMatrix();

			fill(0, 102, 153);
      textAlign( LEFT );
      text( "DETAILS", canvas.x + 90, canvas.y + 20 );
      text( "MADE: " + made(), canvas.x + 20, canvas.y + 80 );
      text( "MISSED: " + missed(), canvas.x + 20, canvas.y + 140 );
      text( "FG%: " + fg(), canvas.x + 20, canvas.y + 200 );
      text( "eFG%: " + efg(), canvas.x + 20, canvas.y + 260 );
		}
	}

	String made() {
		if (currentHex != null) {
			return Integer.toString(currentHex.shotsMade);
		} else {
			return "";
		}
	}

	String missed() {
		if (currentHex != null) {
			return Integer.toString(currentHex.shotsMissed);
		} else {
			return "";
		}
	}

	String fg() {
		if (currentHex != null) {
			return Float.toString(((float)currentHex.shotsMade)/((float)(currentHex.shotsMade + currentHex.shotsMissed)));
		} else {
			return "";
		}
	}

	String efg() {
		if (currentHex != null) {
			return Float.toString(((float)(2*currentHex.twosMade + 3*currentHex.threesMade))/((float)(currentHex.shotsMissed + currentHex.shotsMade)));
		} else {
			return "";
		}
	}

}