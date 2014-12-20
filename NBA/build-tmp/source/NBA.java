import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import de.bezier.data.sql.*; 
import de.bezier.guido.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class NBA extends PApplet {





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


public void setup() {
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
    details = new HexDetails(10.0f);
    details.set_canvas(detailCanvas);
}

public void initController() {
    String user     = "nba";
    String pass     = "hexhex";
    String database = "NBAdb";
    pgsql = new PostgreSQL( this, "localhost", database, user, pass );
    controller = new Controller(pgsql, grid);
    grid.setController(controller);
}


public void draw() {
    background(255);
    grid.display();
    shape(court, 0, 0, courtCanvas.w, courtCanvas.w*28/50);
    detailCanvas.drawRect(220);
    details.display();
    selectionCanvas.drawRect(250);
    selectionUI.display();
}

public void mouseMoved() {
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
public class Canvas {
  float x;
  float y;
  float w;
  float h;
  ArrayList<Canvas> selections;
  
  Canvas(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.selections = new ArrayList<Canvas>();
  } 
  
  // void addSelection(float x, float y, float w, float h)
  // {
  //   if (w < 0) {
  //     x += w;
  //     w *= -1; 
  //   }
  //   if (h < 0) {
  //     y += h;
  //     h *= -1; 
  //   }
  //   selections.add(new Canvas(x, y, w, h));
  //   print("ADDED SELECTION\n");
  // }
  
  // void clearSelections()
  // {
  //   selections = new ArrayList<Canvas>(); 
  // }
  
  // void drawSelections()
  // {
  //   stroke(0, 255, 0);
  //   for (int i = 0; i < selections.size(); i++) {
  //     selections.get(i).drawRect(0, 150, 0);
  //   } 
  // }
  
  public void update(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  public void drawRect(float val)
  {
    stroke(0);
    fill(val);
    strokeWeight(1);
    rect(x, y, w, h); 
  }
  
  public void drawRect(float v1, float v2, float v3)
  {
    stroke(0);
    fill(v1, v2, v3);
    strokeWeight(1);
    rect(x, y, w, h); 
  }
  
  public boolean mouseOver()
  {
    return covers(mouseX, mouseY); 
  }
  
  public boolean covers(float px, float py)
  {
    return (px > x && px < x + w && py > y && py < y + h);
  }
}
public class CheckBox {
    boolean checked;
    float x, y, width, height;
    String label;
    float padx = 6;
    
    CheckBox ( String l, float xx, float yy, float ww, float hh ) {
        label = l;
        x = xx; y = yy; width = ww; height = hh;
        Interactive.add( this );
    }
    
    public void mouseReleased () {
        checked = !checked;
        Interactive.send( this, "checkboxChenged", label, checked );
    }
    
    public void draw () {
        noStroke();
        fill( 200 );
        rect( x, y, width, height );
        if ( checked )
        {
            fill( 80 );
            rect( x+2, y+2, width-4, height-4 );
        }
        fill( 120 );
        textAlign( LEFT );
        text( label, x+width+padx, y+height );
        stroke(0);
    }
    
    // this is a special inside test that includes the label text
    
    public boolean isInside ( float mx, float my ) {
        return Interactive.insideRect( x,y,width+padx+textWidth(label), height, mx, my );
    }
}
public class Controller  {
    PostgreSQL pgsql;
    HexGrid grid;
    String madeLabel = "all";
    String teamLabel = "all";
    boolean[] quarters = {false, false, false, false, false};
    float[] shot_clock = {.0f, 24.0f};
    int totalshotsMade;
    int totalshotsMissed;
    int totalthreesMade;
    int totalthreesMissed;
    int totaltwosMade;
    int totaltwosMissed;
    String displayMode;

    public Controller (PostgreSQL pgsql, HexGrid grid) {
        this.pgsql = pgsql;
        this.grid = grid;
        this.displayMode = "frequency";
        grid.setDisplayMode(this.displayMode);
    }

    public void setDisplayMode(String mode) {
        this.displayMode = mode;
        grid.setDisplayMode(mode);
    }

    public void applaySelection() {
        this.grid.resetHexData();
        if (this.pgsql.connect()) {
            String query = "SELECT x, y, name, shot_made_flag, shot_type FROM shots";
            query += getConditionQuerry();
            println("query: "+query);
            grid.zeroOut();
            this.pgsql.query(query);
            while (this.pgsql.next()) {
                int x = this.pgsql.getInt("x") + 250;
                int y = this.pgsql.getInt("y") + 40;
                String name = this.pgsql.getString("name");
                boolean made = this.pgsql.getBoolean("shot_made_flag");
                String shot_type = this.pgsql.getString("shot_type");
                if (shot_type.equals("2PT Field Goal")) {
                    this.grid.addShot(x, y, name, made, !made, false, false);
                } else if (shot_type.equals("3PT Field Goal")) {
                    this.grid.addShot(x, y, name, false, false, made, !made);
                }
            }
            this.pgsql.close();
        }

        this.totalshotsMade = gettotalshotsMade();
        this.totalshotsMissed = gettotalshotsMissed();
        this.totalthreesMade = gettotalthreesMade();
        this.totalthreesMissed = gettotalthreesMissed();
        this.totaltwosMade = gettotaltwosMade();
        this.totaltwosMissed = gettotaltwosMissed();
    }

    public String getConditionQuerry() {
        String startQuerry = " WHERE 1=1 AND ";
        String quarterQuerry = "";
        String conditionQuerry = "(shot_clock>" + this.shot_clock[0] + " AND shot_clock<" + this.shot_clock[1] + ")";
        for (int i = 0; i < 5; ++i) {
            if (quarters[i]) {
                if (i == 4) {
                    quarterQuerry += " period > 4";
                } else {
                    if (quarterQuerry != "") {
                        quarterQuerry += " OR ";
                    }
                    quarterQuerry += " period=" + str(i+1);
                }
            }
        }
        if (quarterQuerry != "") {
            conditionQuerry += " AND (" + quarterQuerry + ")";
        }
        if (madeLabel != "all") {
            String madeQuerry = "";
            if (madeLabel == "not made") {
                madeQuerry = "shot_made_flag=false";
                
            } else {
                madeQuerry = "shot_made_flag=true";
            }
            conditionQuerry += " AND " + madeQuerry;
        }
        if (teamLabel != "all") {
            conditionQuerry += " AND team_name = '" + teamLabel + "'";
        }
        return startQuerry + conditionQuerry;
    }

    public int gettotalshotsMade() {
        if (this.pgsql.connect()) {
            String query = "SELECT count(*) as count FROM shots";
            query += getConditionQuerry();
            query += " AND shot_made_flag = true";
            this.pgsql.query(query);
            this.pgsql.next();
            int result = this.pgsql.getInt("count");
            pgsql.close();
            return result;
        }
        return 0;
    }

    public int gettotalshotsMissed() {
        if (this.pgsql.connect()) {
            String query = "SELECT count(*) as count FROM shots";
            query += getConditionQuerry();
            query += " AND shot_made_flag = false";
            this.pgsql.query(query);
            this.pgsql.next();
            int count = this.pgsql.getInt("count");
            pgsql.close();
            return count;
        }
        return 0;
    }

    public int gettotalthreesMade() {
        if (this.pgsql.connect()) {
            String query = "SELECT count(*) as count FROM shots";
            query += getConditionQuerry();
            query += " AND shot_made_flag = true AND shot_type = '3PT Field Goal'";
            this.pgsql.query(query);
            this.pgsql.next();
            int count = this.pgsql.getInt("count");
            pgsql.close();
            return count;
        }
        return 0;
    }

    public int gettotalthreesMissed() {
        if (this.pgsql.connect()) {
            String query = "SELECT count(*) as count FROM shots";
            query += getConditionQuerry();
            query += " AND shot_made_flag = false AND shot_type = '3PT Field Goal'";
            this.pgsql.query(query);
            this.pgsql.next();
            int count = this.pgsql.getInt("count");
            pgsql.close();
            return count;
        }
        return 0;
    }

    public int gettotaltwosMade() {
        if (this.pgsql.connect()) {
            String query = "SELECT count(*) as count FROM shots";
            query += getConditionQuerry();
            query += " AND shot_made_flag = true AND shot_type = '2PT Field Goal'";
            this.pgsql.query(query);
            this.pgsql.next();
            int count = this.pgsql.getInt("count");
            pgsql.close();
            return count;
        }
        return 0;
    }

    public int gettotaltwosMissed() {
        if (this.pgsql.connect()) {
            String query = "SELECT count(*) as count FROM shots";
            query += getConditionQuerry();
            query += " AND shot_made_flag = false AND shot_type = '2PT Field Goal'";
            this.pgsql.query(query);
            this.pgsql.next();
            int count = this.pgsql.getInt("count");
            pgsql.close();
            return count;
        }
        return 0;
    }

}
public class HexDetails  {
	Hexagon currentHex = null;
	Canvas canvas;
	PShape  hexShape;

	public HexDetails (float r) {
		this.hexShape = createHex(2*r);
	}

	public void set_newHex(Hexagon newHex) {
		this.currentHex = newHex;
	}

	public void set_canvas(Canvas can) {
		this.canvas = can;
	}

	public void display() {
		if (currentHex != null) {
			pushMatrix();
			translate(currentHex.center[0], currentHex.center[1]);
			fill(0, 0, 255);
			shape(this.hexShape);
			popMatrix();

			fill(0, 102, 153);
      textAlign( LEFT );
      text( "DETAILS", canvas.x + 20, canvas.y + 20 );
      text( "MADE: " + made(), canvas.x + 20, canvas.y + 50 );
      text( "MISSED: " + missed(), canvas.x + 20, canvas.y + 80 );
      text( "FG%: " + fg(), canvas.x + 20, canvas.y + 110 );
      text( "eFG%: " + efg(), canvas.x + 20, canvas.y + 140 );

      text( "TOTALS", canvas.x + 190, canvas.y + 20 );
      text( total_made(), canvas.x + 190, canvas.y + 50 );
      text( total_missed(), canvas.x + 190, canvas.y + 80 );
      text( total_fg(), canvas.x + 190, canvas.y + 110 );
      text( total_efg(), canvas.x + 190, canvas.y + 140 );
		}
	}

	public String made() {
		if (currentHex != null) {
			return Integer.toString(currentHex.shotsMade);
		} else {
			return "";
		}
	}

	public String missed() {
		if (currentHex != null) {
			return Integer.toString(currentHex.shotsMissed);
		} else {
			return "";
		}
	}

	public String fg() {
		if (currentHex != null) {
			return String.format("%.3g%n", 100*((float)currentHex.shotsMade)/((float)(currentHex.shotsMade + currentHex.shotsMissed)));
		} else {
			return "";
		}
	}

	public String efg() {
		if (currentHex != null) {
			return String.format("%.3g%n",100*((float)(currentHex.shotsMade + (0.5f)*(float)currentHex.threesMade))/((float)(currentHex.shotsMissed + currentHex.shotsMade)));
		} else {
			return "";
		}
	}

	public String total_made() {
		if (currentHex != null) {
			return Integer.toString(currentHex.totalshotsMade());
		} else {
			return "";
		}
	}

	public String total_missed() {
		if (currentHex != null) {
			return Integer.toString(currentHex.totalshotsMissed());
		} else {
			return "";
		}
	}

	public String total_fg() {
		if (currentHex != null) {
			return String.format("%.3g%n", 100*((float)currentHex.totalshotsMade())/((float)(currentHex.totalshotsMade() + currentHex.totalshotsMissed())));
		} else {
			return "";
		}
	}

	public String total_efg() {
		if (currentHex != null) {
			return String.format("%.3g%n",100*((float)(currentHex.totalshotsMade() + (0.5f)*(float)currentHex.totalthreesMade()))/((float)(currentHex.totalshotsMissed() + currentHex.totalshotsMade())));
		} else {
			return "";
		}
	}

}
public class HexGrid  {
	int[] size;
	float r;
	Hexagon[][] grid;
	PShape  hexShape;
	Canvas c;
	int maxVal = 0;
	float scale;
	Controller controller;
	String displayMode;

	public HexGrid (int[] size, float r, Canvas canvas) {
		this.size = size;
		this.r = r;
		this.c = canvas;
		this.grid = new Hexagon[size[0]][size[1]];
		this.displayMode = "frequency";
		this.hexShape = createHex(this.r);
		this.createGrid();
		this.scale = min(canvas.w/500, canvas.h/350);
	}

	public void setController(Controller c) {
		this.controller = c;
	}

	public void createGrid() {
		for (int iy = 0; iy < this.size[1]; ++iy) {
			for (int ix = 0; ix < this.size[0]; ++ix) {
				int[] c = {ix, iy};
				float[] center = this.get_hexCenter(c);
				grid[ix][iy] = new Hexagon(this.hexShape, center, this, displayMode);
			}
		}
	}

	public void setDisplayMode(String mode) {
		this.displayMode = mode;
		for (Hexagon[] hexCol : this.grid) {
			for (Hexagon h : hexCol) {
				h.setDisplayMode(mode);
			}
		}

	}

	public void display() {
		float t = 1;
		float maxVal = 0.0f;
		for (Hexagon[] hexCol : this.grid) {
			for (Hexagon h : hexCol) {
				float hexval = h.getVal();
				if (hexval > maxVal)
					maxVal = hexval;
			}
		}

		float logmaxVal;
		if (displayMode == "frequency") {
			logmaxVal = pow(maxVal, .33f);
		} else {
			logmaxVal = maxVal;
		}
		for (Hexagon[] hexCol : this.grid) {
			for (Hexagon h : hexCol) {
				fill(t);
				t += 1;
				h.display(logmaxVal);
			}
		}
	}

	public boolean addShot(int x, int y, String playerName, boolean twoMade, boolean twoMissed,
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

	public void resetHexData() {
		for (Hexagon[] hexCol : this.grid) {
			for (Hexagon h : hexCol) {
				h.resetData();
			}
		}
	}

	public Hexagon get_hexagon_fromXY(float x, float y) {
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

	public Hexagon get_hexagon_fromIndex(int[] index) {
		int ix = index[0] + index[1]/2;
		int iy = index[1];
		return grid[ix][iy];
	}

	public int[] get_hexIndex_from_xy(int x, int y) {
		int q = round((sqrt(3)*x/3 - y/3)/this.r);
		int p = round((2*y)/(3*this.r));
		return new int[] {q, p};
	}

	public int[] get_hexIndex_from_index(int[] index) {
		index[0] = index[0] - index[1]/2;
		return index;
	}

	public float[] get_hexCenter(int[] coords){
		int hexCords[] = this.get_hexIndex_from_index(coords);
		float h = (this.r*sqrt(3)/2);
		float[] vec = {h*(2*hexCords[0] + hexCords[1]), 1.5f*this.r*hexCords[1]};
		return vec;
	}

	public void update_maxVal() {
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

	public void zeroOut() {
		for (Hexagon[] hexCol : this.grid) {
			for (Hexagon h : hexCol) {
				h.zeroOut();
			}
		}
	}

	public int totalshotsMade() {
		return controller.totalshotsMade;
	}

	public int totalshotsMissed() {
		return controller.totalshotsMissed;
	}

	public int totalthreesMade() {
		return controller.totalthreesMade;
	}

	public int totalthreesMissed() {
		return controller.totalthreesMissed;
	}

	public int totaltwosMade() {
		return controller.totaltwosMade;
	}

	public int totaltwosMissed() {
		return controller.totaltwosMissed;
	}

}

public class Hexagon  {
	float[] center;
	PShape hexShape;
	IntDict shots;
	int shotsMade, shotsMissed, threesMade, threesMissed, twosMade, twosMissed;
	boolean selected = false;
	int maxVal = 3; // brightness
	HexGrid hexGrid;
	String displayMode;

	public Hexagon (PShape hexShape, float[] center, HexGrid g, String display) {
		this.hexShape = hexShape;
		this.center = center;
		this.zeroOut();
		this.hexGrid = g;
		this.displayMode = display;
	}

	public void setDisplayMode(String mode) {
		this.displayMode = mode;
	}

	public void zeroOut() {
		this.shots = new IntDict();
		this.shotsMade = 0;
		this.shotsMissed = 0;
		this.threesMade = 0;
		this.threesMissed = 0;
		this.twosMade = 0;
		this.twosMissed = 0;
		this.shots.set("", 0);
	}

	public float getVal() {
		if (displayMode == "fg") {
			int totalShots = shotsMissed + shotsMade;
			if (totalShots == 0) {
				return 0.0f;
			} else {
				return (float)shotsMade/((float)shotsMissed + (float)(shotsMade));
			}
		} else if (displayMode == "efg") {
			int totalShots = shotsMissed + shotsMade;
			if (totalShots == 0) {
				return 0.0f;
			} else {
				return ((float)(shotsMade) + (0.5f * threesMade))/((float)shotsMissed + (float)(shotsMade));
			}
		} else {
			return shotsMade + shotsMissed;
		}
	}

	public void display(float logmaxVal) {
		// Calc shot accuracy
		float val = getVal();
		float ratio;
		if (displayMode == "frequency") {
			float logval = pow(val, .33f);
			ratio = logval/logmaxVal;
		} else {
			ratio = val/logmaxVal;
		}
		fill(255, 255 - 255.0f*ratio, 255 - 255.0f*ratio);
		pushMatrix();
		translate(this.center[0], this.center[1]);
		shape(this.hexShape);
		popMatrix();
	}

	public void addShot(String playerName, boolean twoMade, boolean twoMissed,
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

	public void set_selected(boolean b)  {
		this.selected = b;
	}

	public void set_maxVal(int maxVal) {
		this.maxVal = maxVal;
	}

	public void resetData() {
		this.shots = new IntDict();
		this.shots.set("", 0);
	}

	public int totalshotsMade() {
		return hexGrid.totalshotsMade();
	}

	public int totalshotsMissed() {
		return hexGrid.totalshotsMissed();
	}

	public int totalthreesMade() {
		return hexGrid.totalthreesMade();
	}

	public int totalthreesMissed() {
		return hexGrid.totalthreesMissed();
	}

	public int totaltwosMade() {
		return hexGrid.totaltwosMade();
	}

	public int totaltwosMissed() {
		return hexGrid.totaltwosMissed();
	}
}

public PShape createHex(float r) {
	PShape hexShape = createShape();
	hexShape.beginShape();
	float h = r*sqrt(3)/2;
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

public class MadeButton {
    float x, y, width, height;
    boolean on = true;
    String label;
    float padx = 6;
    float pady = 3;
    int currentLabel = 0;
    Selection selection;
    
    MadeButton ( float xx, float yy, float w, float h, String label, boolean selected, Selection my_selection) {
        x = xx; y = yy; width = w; height = h;
        this.on = selected;
        this.label = label;
        Interactive.add( this ); // register it with the manager
        this.selection = my_selection;
    }

    public void turnOn() {
        this.on = true;
    }

    public void turnOff() {
        this.on = false;
    }
    
    // called by manager
    
    public void mousePressed () {
        println("MOUSE PRESSED in " + label);
        // on = !on;
    }
    public void mouseReleased () {
        // println("MOUSE RELEASED in " + label);
        // Interactive.send( this, label);
        selection.notifyFromButton(label);
    }

    public void draw () {
        if ( on ) fill( 100 );
        else fill( 200 );
        noStroke();
        rect(x, y, width, height, 7);
        textAlign( CENTER );
        if (on) fill( 200 );
        else fill( 100 );
        text( label, x+(width/2), y+(height/2) + pady );
        stroke(0);
    }

    public boolean isInside ( float mx, float my ) {
        return Interactive.insideRect( x,y,width+padx+textWidth(label), height, mx, my );
    }
}
public class MultiSlider
{
    float x,y,width,height;
    float pressedX, pressedY;
    float pressedXLeft, pressedYLeft, pressedXRight, pressedYRight;
    boolean on = false;
    
    SliderHandle left, right, activeHandle;
    
    float values[];
    
    MultiSlider ( float xx, float yy, float ww, float hh )
    {
        this.x = xx; this.y = yy; this.width = ww; this.height = hh;
        
        left  = new SliderHandle( x, y, height, height );
        right = new SliderHandle( x+width-height, y, height, height );
        
        values = new float[]{0,1};
        
        Interactive.add( this );
    }
    
    public void mouseEntered ()
    {
        on = true;
    }
    
    public void mouseExited ()
    {
        on = false;
    }
    
    public void mousePressed ( float mx, float my )
    {
        if ( left.isInside( mx, my ) )       activeHandle = left;
        else if ( right.isInside( mx, my ) ) activeHandle = right;
        else                                 activeHandle = null;
        
        pressedX = mx;
        pressedXLeft  = left.x;
        pressedXRight = right.x;
    }

    public void mouseReleased() {
        Interactive.send( this, "applayVal");
    }
    
    public void mouseDragged ( float mx, float my )
    {
        float vx = mx - left.width/2;
        vx = constrain( vx, x, x+width-left.width );
        
        if ( activeHandle == left )
        {
            if ( vx > right.x-left.width ) vx = right.x-left.width;
            values[0] = map( vx, x, x+width-left.width, 0, 1 );
            
            Interactive.send( this, "valueChanged", values[0] , values[1] );
        }
        else if ( activeHandle == right )
        {
            if ( vx < left.x+left.width ) vx = left.x+left.width;
            values[1] = map( vx, x, x+width-left.width, 0, 1 );
            
            Interactive.send( this, "valueChanged", values[0] , values[1] );
        }
        else // dragging in between handles
        {
            float dx = mx-pressedX;
            
            if ( pressedXLeft + dx >= x && pressedXRight + dx <= x+(width-right.width) )
            {
                values[0] = map( pressedXLeft + dx,  x, x+width-left.width, 0, 1 );
                left.x = pressedXLeft + dx;
                
                values[1] = map( pressedXRight + dx, x, x+width-left.width, 0, 1 );
                right.x = pressedXRight + dx;
                
                Interactive.send( this, "valueChanged", values[0] , values[1] );
            }
        }
        
        if ( activeHandle != null ) activeHandle.x = vx;
    }
    
    public void draw ()
    {
        noStroke();
        fill( 120 );
        rect( x, y, width, height );
        fill( on ? 200 : 150 );
        rect( left.x, left.y, right.x-left.x+right.width, right.height );
        text("0", x ,y+25);
        text("12", x+width/2-textWidth("12") ,y+25);
        text("24 s", x+width-textWidth("24") ,y+25);
    }
    
    public boolean isInside ( float mx, float my )
    {
        return left.isInside(mx,my) || right.isInside(mx,my) || Interactive.insideRect( left.x, left.y, (right.x+right.width)-left.x, height, mx, my );
    }
}

class SliderHandle
{
    float x,y,width,height;
    
    SliderHandle ( float xx, float yy, float ww, float hh )
    {
        this.x = xx; this.y = yy; this.width = ww; this.height = hh;
    }
    
    public void draw ()
    {
        rect( x, y, width, height );
    }
    
    public boolean isInside ( float mx, float my )
    {
        return Interactive.insideRect( x, y, width, height, mx, my );
    }
}
public class Selection {
    Canvas c;
    CheckBox[] quartersBtn;
    ArrayList<MadeButton> shotSelectionBtns;
    MadeButton allBtn;
    MadeButton shotMadeBtn;
    MadeButton shotMissedBtn;
    ArrayList<MadeButton> displayTypeBtns;
    MadeButton frequencyBtn;
    MadeButton fgBtn;
    MadeButton efgBtn;
    ArrayList<MadeButton> teamSelectBtns;
    MadeButton allTeamsBtn;
    MadeButton hawksBtn;
    MadeButton celticsBtn;
    MadeButton netsBtn;
    MadeButton bobcatsBtn;
    MadeButton bullsBtn;
    MadeButton cavsBtn;
    MadeButton mavsBtn;
    MadeButton nuggetsBtn;
    MadeButton pistonsBtn;
    MadeButton warriorsBtn;
    MadeButton rocketsBtn;
    MadeButton pacersBtn;
    MadeButton clippersBtn;
    MadeButton lakersBtn;
    MadeButton grizzliesBtn;
    MadeButton heatBtn;
    MadeButton bucksBtn;
    MadeButton twolvesBtn;
    MadeButton pelicansBtn;
    MadeButton knicksBtn;
    MadeButton thunderBtn;
    MadeButton magicBtn;
    MadeButton sixersBtn;
    MadeButton sunsBtn;
    MadeButton blazersBtn;
    MadeButton kingsBtn;
    MadeButton spursBtn;
    MadeButton raptorsBtn;
    MadeButton jazzBtn;
    MadeButton wizardsBtn;
    MultiSlider clockSlider;
    Controller my_controller;

    public Selection (Canvas canvas, Controller controller) {
        this.c = canvas;
        this.my_controller = controller;
        quartersBtn = new CheckBox[5];
        for ( int i = 0; i < 4; ++i ) {
            quartersBtn[i] = new CheckBox( str(i+1), c.x + 20 + i*40, c.y + 150, 10, 10 );
            Interactive.on( quartersBtn[i], "checkboxChenged",  this, "quarterChanged" );
        }
        quartersBtn[4] = new CheckBox( "OT", c.x + 180, c.y + 150, 10, 10);
        Interactive.on( quartersBtn[4], "checkboxChenged", this, "quarterChanged");

        allBtn = new MadeButton(c.x + 20, c.y + 30, 50, 15, "all", true, this);
        shotMadeBtn = new MadeButton(c.x + 80, c.y + 30, 50, 15, "made", false, this);
        shotMissedBtn = new MadeButton(c.x + 140, c.y + 30, 50, 15, "missed", false, this);
        
        shotSelectionBtns = new ArrayList<MadeButton>();
        shotSelectionBtns.add(allBtn);
        shotSelectionBtns.add(shotMadeBtn);
        shotSelectionBtns.add(shotMissedBtn);

        frequencyBtn = new MadeButton(c.x + 20, c.y + 90, 80, 15, "Frequency", true, this);
        Interactive.on( frequencyBtn, "Frequency", this, "frequencyOn");

        fgBtn = new MadeButton(c.x + 120, c.y + 90, 80, 15, "FG%", false, this);
        Interactive.on( fgBtn, "FG%", this, "fgOn");

        efgBtn = new MadeButton(c.x + 220, c.y + 90, 80, 15, "eFG%", false, this);
        Interactive.on( efgBtn, "eFG%", this, "efgOn");
        
        displayTypeBtns = new ArrayList<MadeButton>();
        displayTypeBtns.add(frequencyBtn);
        displayTypeBtns.add(fgBtn);
        displayTypeBtns.add(efgBtn);

        allTeamsBtn = new MadeButton(c.x + 20, c.y + 240, 40, 15, "All", true, this);
        
        hawksBtn = new MadeButton(c.x + 20, c.y + 260, 40, 15, "ATL", false, this);
        celticsBtn = new MadeButton(c.x + 70, c.y + 260, 40, 15, "BOS", false, this);
        netsBtn = new MadeButton(c.x + 120, c.y + 260, 40, 15, "BKN", false, this);
        bobcatsBtn = new MadeButton(c.x + 170, c.y + 260, 40, 15, "CHA", false, this);
        bullsBtn = new MadeButton(c.x + 220, c.y + 260, 40, 15, "CHI", false, this);
        cavsBtn = new MadeButton(c.x + 270, c.y + 260, 40, 15, "CLE", false, this);

        mavsBtn = new MadeButton(c.x + 20, c.y + 280, 40, 15, "DAL", false, this);
        nuggetsBtn = new MadeButton(c.x + 70, c.y + 280, 40, 15, "DEN", false, this);
        pistonsBtn = new MadeButton(c.x + 120, c.y + 280, 40, 15, "DET", false, this);
        warriorsBtn = new MadeButton(c.x + 170, c.y + 280, 40, 15, "GSW", false, this);
        rocketsBtn = new MadeButton(c.x + 220, c.y + 280, 40, 15, "HOU", false, this);
        pacersBtn = new MadeButton(c.x + 270, c.y + 280, 40, 15, "IND", false, this);
        
        clippersBtn = new MadeButton(c.x + 20, c.y + 300, 40, 15, "LAC", false, this);
        lakersBtn = new MadeButton(c.x + 70, c.y + 300, 40, 15, "LAL", false, this);
        grizzliesBtn = new MadeButton(c.x + 120, c.y + 300, 40, 15, "MEM", false, this);
        heatBtn = new MadeButton(c.x + 170, c.y + 300, 40, 15, "MIA", false, this);
        bucksBtn = new MadeButton(c.x + 220, c.y + 300, 40, 15, "MIL", false, this);
        twolvesBtn = new MadeButton(c.x + 270, c.y + 300, 40, 15, "MIN", false, this);
        
        pelicansBtn = new MadeButton(c.x + 20, c.y + 320, 40, 15, "NOH", false, this);
        knicksBtn = new MadeButton(c.x + 70, c.y + 320, 40, 15, "NYK", false, this);
        thunderBtn = new MadeButton(c.x + 120, c.y + 320, 40, 15, "OKC", false, this);
        magicBtn = new MadeButton(c.x + 170, c.y + 320, 40, 15, "ORL", false, this);
        sixersBtn = new MadeButton(c.x + 220, c.y + 320, 40, 15, "PHI", false, this);
        sunsBtn = new MadeButton(c.x + 270, c.y + 320, 40, 15, "PHX", false, this);
        
        blazersBtn = new MadeButton(c.x + 20, c.y + 340, 40, 15, "POR", false, this);
        kingsBtn = new MadeButton(c.x + 70, c.y + 340, 40, 15, "SAC", false, this);
        spursBtn = new MadeButton(c.x + 120, c.y + 340, 40, 15, "SAS", false, this);
        raptorsBtn = new MadeButton(c.x + 170, c.y + 340, 40, 15, "TOR", false, this);
        jazzBtn = new MadeButton(c.x + 220, c.y + 340, 40, 15, "UTA", false, this);
        wizardsBtn = new MadeButton(c.x + 270, c.y + 340, 40, 15, "WAS", false, this);


        teamSelectBtns = new ArrayList<MadeButton>();
        teamSelectBtns.add(allTeamsBtn);
        teamSelectBtns.add(hawksBtn);
        teamSelectBtns.add(celticsBtn);
        teamSelectBtns.add(netsBtn);
        teamSelectBtns.add(bobcatsBtn);
        teamSelectBtns.add(bullsBtn);
        teamSelectBtns.add(cavsBtn);
        teamSelectBtns.add(mavsBtn);
        teamSelectBtns.add(nuggetsBtn);
        teamSelectBtns.add(pistonsBtn);
        teamSelectBtns.add(warriorsBtn);
        teamSelectBtns.add(rocketsBtn);
        teamSelectBtns.add(pacersBtn);
        teamSelectBtns.add(clippersBtn);
        teamSelectBtns.add(lakersBtn);
        teamSelectBtns.add(grizzliesBtn);
        teamSelectBtns.add(heatBtn);
        teamSelectBtns.add(bucksBtn);
        teamSelectBtns.add(twolvesBtn);
        teamSelectBtns.add(pelicansBtn);
        teamSelectBtns.add(knicksBtn);
        teamSelectBtns.add(thunderBtn);
        teamSelectBtns.add(magicBtn);
        teamSelectBtns.add(sixersBtn);
        teamSelectBtns.add(sunsBtn);
        teamSelectBtns.add(blazersBtn);
        teamSelectBtns.add(kingsBtn);
        teamSelectBtns.add(spursBtn);
        teamSelectBtns.add(raptorsBtn);
        teamSelectBtns.add(jazzBtn);
        teamSelectBtns.add(wizardsBtn);

        clockSlider = new MultiSlider( c.x + 20, c.y+200, c.w-40, 10 );
        Interactive.on( clockSlider, "valueChanged",  this, "clockChanged" );
        Interactive.on( clockSlider, "applayVal",  this, "applay" );
    }

    public void display() {
        fill(0, 102, 153);
        textAlign( LEFT );
        text( "SHOTS", c.x + 20, c.y + 20 );
        text( "DISPLAY TYPE", c.x + 20, c.y + 80 );
        text( "QUARTERS", c.x + 20, c.y + 140 );
        text( "SHOT CLOCK", c.x + 20, c.y + 190 );
        for (CheckBox b : quartersBtn) {
            b.draw();
        }
        text( "OFFENSE", c.x + 20, c.y + 235);
    }

    public void applay() {
        controller.applaySelection();
    }

    public void madeChanged(String label) {
        controller.madeLabel = label;
        controller.applaySelection();
    }

    public void teamChanged(String label) {
        controller.teamLabel = label;
        controller.applaySelection();
    }

    public void notifyFromButton(String label) {
        println(" notify from button called with label " + label);
        if (label.equals("all")) {
            allOn();
        } else if (label.equals("made")) {
            shotMadeOn();
        } else if (label.equals("missed")) {
            shotMissedOn();
        } else if (label.equals("Frequency")) {
            frequencyOn();
        } else if (label.equals("FG%")) {
            fgOn();
        } else if (label.equals("eFG%")) {
            efgOn();
        } else if (label.equals("All")) {
            allTeamsOn();
        } else if (label.equals("ATL")) {
            hawksOn();
        } else if (label.equals("BOS")) {
            celticsOn();
        } else if (label.equals("BKN")) {
            netsOn();
        } else if (label.equals("CHA")) {
            bobcatsOn();
        } else if (label.equals("CHI")) {
            bullsOn();
        } else if (label.equals("CLE")) {
            cavsOn();
        } else if (label.equals("DAL")) {
            mavsOn();
        } else if (label.equals("DEN")) {
            nuggetsOn();
        } else if (label.equals("DET")) {
            pistonsOn();
        } else if (label.equals("GSW")) {
            warriorsOn();
        } else if (label.equals("HOU")) {
            rocketsOn();
        } else if (label.equals("IND")) {
            pacersOn();
        } else if (label.equals("LAC")) {
            clippersOn();
        } else if (label.equals("LAL")) {
            lakersOn();
        } else if (label.equals("MEM")) {
            grizzliesOn();
        } else if (label.equals("MIA")) {
            heatOn();
        } else if (label.equals("MIL")) {
            bucksOn();
        } else if (label.equals("MIN")) {
            twolvesOn();
        } else if (label.equals("NOH")) {
            pelicansOn();
        } else if (label.equals("NYK")) {
            knicksOn();
        } else if (label.equals("OKC")) {
            thunderOn();
        } else if (label.equals("ORL")) {
            magicOn();
        } else if (label.equals("PHI")) {
            sixersOn();
        } else if (label.equals("PHX")) {
            sunsOn();
        } else if (label.equals("POR")) {
            blazersOn();
        } else if (label.equals("SAC")) {
            kingsOn();
        } else if (label.equals("SAS")) {
            spursOn();
        } else if (label.equals("TOR")) {
            raptorsOn();
        } else if (label.equals("UTA")) {
            jazzOn();
        } else if (label.equals("WAS")) {
            wizardsOn();
        }
    }

    public void allOn() {
        for (MadeButton b : shotSelectionBtns) {
            b.turnOff();
        }
        allBtn.turnOn();
        madeChanged("all");
    }

    public void shotMissedOn() {
        for (MadeButton b : shotSelectionBtns) {
            b.turnOff();
        }
        shotMissedBtn.turnOn();
        madeChanged("not made");
    }

    public void shotMadeOn() {
        for (MadeButton b : shotSelectionBtns) {
            b.turnOff();
        }
        shotMadeBtn.turnOn();
        madeChanged("made");
    }

    public void frequencyOn() {
        for (MadeButton b : displayTypeBtns) {
            b.turnOff();
        }
        frequencyBtn.turnOn();
        controller.setDisplayMode("frequency");
    }

    public void fgOn() {
        for (MadeButton b : displayTypeBtns) {
            b.turnOff();
        }
        fgBtn.turnOn();
        controller.setDisplayMode("fg");
    }

    public void efgOn() {
        for (MadeButton b : displayTypeBtns) {
            b.turnOff();
        }
        efgBtn.turnOn();
        controller.setDisplayMode("efg");
    }

    public void allTeamsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        allTeamsBtn.turnOn();
        teamChanged("all");
    }

    public void hawksOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        hawksBtn.turnOn();
        teamChanged("Atlanta Hawks");
    }
    public void celticsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        celticsBtn.turnOn();
        teamChanged("Boston Celtics");
    }
    public void netsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        netsBtn.turnOn();
        teamChanged("Brooklyn Nets");
    }
    public void bobcatsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        bobcatsBtn.turnOn();
        teamChanged("Charlotte Bobcats");
    }
    public void bullsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        bullsBtn.turnOn();
        teamChanged("Chicago Bulls");
    }
    public void cavsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        cavsBtn.turnOn();
        teamChanged("Cleveland Cavaliers");
    }
    public void mavsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        mavsBtn.turnOn();
        teamChanged("Dallas Mavericks");
    }
    public void nuggetsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        nuggetsBtn.turnOn();
        teamChanged("Denver Nuggets");
    }
    public void pistonsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        pistonsBtn.turnOn();
        teamChanged("Detroit Pistons");
    }
    public void warriorsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        warriorsBtn.turnOn();
        teamChanged("Golden State Warriors");
    }
    public void rocketsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        rocketsBtn.turnOn();
        teamChanged("Houston Rockets");
    }
    public void pacersOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        pacersBtn.turnOn();
        teamChanged("Indiana Pacers");
    }
    public void clippersOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        clippersBtn.turnOn();
        teamChanged("Los Angeles Clippers");
    }
    public void lakersOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        lakersBtn.turnOn();
        teamChanged("Los Angeles Lakers");
    }
    public void grizzliesOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        grizzliesBtn.turnOn();
        teamChanged("Memphis Grizzlies");
    }
    public void heatOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        heatBtn.turnOn();
        teamChanged("Miami Heat");
    }
    public void bucksOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        bucksBtn.turnOn();
        teamChanged("Milwaukee Bucks");
    }
    public void twolvesOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        twolvesBtn.turnOn();
        teamChanged("Minnesota Timberwolves");
    }
    public void pelicansOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        pelicansBtn.turnOn();
        teamChanged("New Orleans Pelicans");
    }
    public void knicksOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        knicksBtn.turnOn();
        teamChanged("New York Knicks");
    }
    public void thunderOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        thunderBtn.turnOn();
        teamChanged("Oklahoma City Thunder");
    }
    public void magicOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        magicBtn.turnOn();
        teamChanged("Orlando Magic");
    }
    public void sixersOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        sixersBtn.turnOn();
        teamChanged("Philadelphia 76ers");
    }
    public void sunsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        sunsBtn.turnOn();
        teamChanged("Phoenix Suns");
    }
    public void blazersOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        blazersBtn.turnOn();
        teamChanged("Portland Trail Blazers");
    }
    public void kingsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        kingsBtn.turnOn();
        teamChanged("Sacramento Kings");
    }
    public void spursOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        spursBtn.turnOn();
        teamChanged("San Antonio Spurs");
    }
    public void raptorsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        raptorsBtn.turnOn();
        teamChanged("Toronto Raptors");
    }
    public void jazzOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        jazzBtn.turnOn();
        teamChanged("Utah Jazz");
    }
    public void wizardsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        wizardsBtn.turnOn();
        teamChanged("Washington Wizards");
    }

    public void clockChanged(float minVal, float maxVal) {
        controller.shot_clock[0] = minVal*24;
        controller.shot_clock[1] = maxVal*24;
        // controller.applaySelection();
    }

    public void quarterChanged(String label, boolean checked) {
        if (label == "OT") {
            controller.quarters[4] = checked;
            controller.applaySelection();
        } else {
            int i = PApplet.parseInt(label);
            controller.quarters[i-1] = checked;
            controller.applaySelection();
        }
    }

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "NBA" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
