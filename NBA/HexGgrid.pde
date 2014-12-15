public class HexGrid  {
	int[] size;
	float r;
	Hexagon[][] grid;
	PShape  hexShape;
	Canvas c;
	int maxVal = 0;
	float scale;

	public HexGrid (int[] size, float r, Canvas canvas) {
		this.size = size;
		this.r = r;
		this.c = canvas;
		this.grid = new Hexagon[size[0]][size[1]];
		this.hexShape = createHex(this.r);
		this.createGrid();
		this.scale = min(canvas.w/500, canvas.h/350);
	}

	void createGrid() {
		for (int iy = 0; iy < this.size[1]; ++iy) {
			for (int ix = 0; ix < this.size[0]; ++ix) {
				int[] c = {ix, iy};
				float[] center = this.get_hexCenter(c);
				grid[ix][iy] = new Hexagon(this.hexShape, center);
			}
		}
	}

	void display() {
		float t = 1;
		for (Hexagon[] hexCol : this.grid) {
			for (Hexagon h : hexCol) {
				fill(t);
				t += 1;
				h.display();
			}
		}
	}

	boolean addShot(int x, int y, String playerName, boolean twoMade, boolean twoMissed,
																										boolean threeMade, boolean threeMissed) {
		try {
			float x_scaled = x*this.scale;
			float y_scaled = y*this.scale;
			Hexagon currHex = this.get_hexagon_fromXY(x_scaled, y_scaled);
			currHex.addShot(playerName, twoMade, twoMissed, threeMade, threeMissed);
			return true;
		} catch (ArrayIndexOutOfBoundsException e) {
			// println("out of bound");
			return false;
		}
	}

	void resetHexData() {
		for (Hexagon[] hexCol : this.grid) {
			for (Hexagon h : hexCol) {
				h.resetData();
			}
		}
	}

	Hexagon get_hexagon_fromXY(float x, float y) {
		int q = round((sqrt(3)*x/3 - y/3)/this.r);
		int p = round((2*y)/(3*this.r));
		// Hexagon curhex;
		// try {
		return this.get_hexagon_fromIndex(new int[] {q, p});
		// } catch (ArrayIndexOutOfBoundsException e) {
		// 	print("p: "+p);
		// 	print(" q: "+q);
		// 	print(" x: "+x);
		// 	print(" y: "+y);
		// 	println(" this.r: "+this.r);
		// 	return null;
		// }
	}

	Hexagon get_hexagon_fromIndex(int[] index) {
		int ix = index[0] + index[1]/2;
		int iy = index[1];
		return grid[ix][iy];
	}

	int[] get_hexIndex_from_xy(int x, int y) {
		int q = round((sqrt(3)*x/3 - y/3)/this.r);
		int p = round((2*y)/(3*this.r));
		return new int[] {q, p};
	}

	int[] get_hexIndex_from_index(int[] index) {
		index[0] = index[0] - index[1]/2;
		return index;
	}

	float[] get_hexCenter(int[] coords){
		int hexCords[] = this.get_hexIndex_from_index(coords);
		float h = (this.r*sqrt(3)/2);
		float[] vec = {h*(2*hexCords[0] + hexCords[1]), 1.5*this.r*hexCords[1]};
		return vec;
	}

	void update_maxVal() {
		for (Hexagon[] hexCol : this.grid) {
			for (Hexagon h : hexCol) {
				this.maxVal = max(max(h.shots.valueArray()), maxVal);
			}
		}
		for (Hexagon[] hexCol : this.grid) {
			for (Hexagon h : hexCol) {
				h.set_maxVal(this.maxVal);
			}
		}
	}

}