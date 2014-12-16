
public class Hexagon  {
	float[] center;
	PShape hexShape;
	IntDict shots;
	int shotsMade, shotsMissed, threesMade, threesMissed, twosMade, twosMissed;
	boolean selected = false;
	int maxVal = 3; // brightness

	public Hexagon (PShape hexShape, float[] center) {
		this.hexShape = hexShape;
		this.center = center;
		this.zeroOut();
	}

	void zeroOut() {
		this.shots = new IntDict();
		this.shotsMade = 0;
		this.shotsMissed = 0;
		this.threesMade = 0;
		this.threesMissed = 0;
		this.twosMade = 0;
		this.twosMissed = 0;
		this.shots.set("", 0);
	}

	float getVal() {
		// return max(shots.valueArray())*10/this.maxVal;
		return shotsMade + shotsMissed;
	}

	void display(float logmaxVal) {
		// Calc shot accuracy
		float val = getVal();
		float logval = pow(val, .33);
		float ratio = logval/logmaxVal;
		// fill(200 - val, 0, 0);
		fill(255, 255 - 255.0*ratio, 255 - 255.0*ratio);
		pushMatrix();
		translate(this.center[0], this.center[1]);
		shape(this.hexShape);
		popMatrix();
	}

	void addShot(String playerName, boolean twoMade, boolean twoMissed,
																	boolean threeMade, boolean threeMissed) {
		int allNum = 0;
		if (this.shots.hasKey(playerName)) {
			allNum = this.shots.get(playerName) + 1;
		}
		this.shots.set(playerName, allNum);

		if (twoMade || threeMade) {
			this.shotsMade += 1;
		}
		if (twoMissed || threeMissed) {
			this.shotsMissed += 1;
		}
		if (threeMade) {
			this.threesMade += 1;
		}
		if (threeMissed) {
			this.threesMissed += 1;
		}
		if (twoMade) {
			this.twosMade += 1;
		}
		if (twoMissed) {
			this.twosMissed += 1;
		}
	}

	void set_selected(boolean b)  {
		this.selected = b;
	}

	void set_maxVal(int maxVal) {
		this.maxVal = maxVal;
	}

	void resetData() {
		this.shots = new IntDict();
		this.shots.set("", 0);
	}
}

PShape createHex(float r) {
	PShape hexShape = createShape();
	hexShape.beginShape();
	float h = r*sqrt(3)/2;
	// hexShape.fill(100);
	hexShape.vertex(0, -r);
	hexShape.vertex(h, -r/2);
	hexShape.vertex(h,  r/2);
	hexShape.vertex(0, r);
	hexShape.vertex(-h,  r/2);
	hexShape.vertex(-h, -r/2);
	hexShape.endShape(CLOSE);
	hexShape.disableStyle();
	return hexShape;
}

