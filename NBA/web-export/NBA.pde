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
    size(1300, 700, P2D);
    Interactive.make(this);
    courtCanvas = new Canvas(0, 0, 1000, 700);
    // detailCanvas = new Canvas(1000, 0, 300, 300);
    selectionCanvas = new Canvas(1000, 0, 300, 700);
    radius = courtCanvas.w/((gridSize[0] -1 )*sqrt(3));
    grid = new HexGrid(gridSize, radius, courtCanvas);
    initController();
    selectionUI = new Selection(selectionCanvas, controller);
    controller.applaySelection();
    court = loadShape("img/NBA_ready.svg");
    grid.hexShape.fill(200);
}

void initController() {
    String user     = "nba";
    String pass     = "hexhex";
    String database = "NBAdb";
    pgsql = new PostgreSQL( this, "localhost", database, user, pass );
    controller = new Controller(pgsql, grid);
}


void draw() {
    background(255);
    grid.display();
    shape(court, 0, 0, courtCanvas.w, courtCanvas.w*28/50);
    // hexagon.display();
    // details.display();
    // detailCanvas.drawRect(220);
    selectionCanvas.drawRect(250);
    selectionUI.display();
}


// void mouseMoved() {
//     try {
//         Hexagon newHex = grid.get_hexagon_fromXY(mouseX, mouseY);
//         if (newHex != selectedHex) {
//             if (selectedHex != null) {
//                 // selectedHex.set_selected(false);
//             }
//             selectedHex = newHex;
//             // selectedHex.set_selected(true);
//             // details.set_newHex(newHex);
//         }
//     } catch (ArrayIndexOutOfBoundsException e) {
//         // selectedHex.set_selected(false);
//         selectedHex = null;
//         // details.set_newHex(null);
//     }
// }
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
  
  void update(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  void drawRect(float val)
  {
    stroke(0);
    fill(val);
    strokeWeight(1);
    rect(x, y, w, h); 
  }
  
  void drawRect(float v1, float v2, float v3)
  {
    stroke(0);
    fill(v1, v2, v3);
    strokeWeight(1);
    rect(x, y, w, h); 
  }
  
  boolean mouseOver()
  {
    return covers(mouseX, mouseY); 
  }
  
  boolean covers(float px, float py)
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
    
    void mouseReleased () {
        checked = !checked;
        Interactive.send( this, "checkboxChenged", label, checked );
    }
    
    void draw () {
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
    
    boolean isInside ( float mx, float my ) {
        return Interactive.insideRect( x,y,width+padx+textWidth(label), height, mx, my );
    }
}
public class Controller  {
    PostgreSQL pgsql;
    HexGrid grid;
    String madeLabel = "all";
    boolean[] quarters = {false, false, false, false, false};
    float[] shot_clock = {.0, 24.0};

    public Controller (PostgreSQL pgsql, HexGrid grid) {
        this.pgsql = pgsql;
        this.grid = grid;
    }

    void applaySelection() {
        this.grid.resetHexData();
        if (this.pgsql.connect()) {
            String query = "SELECT x, y, name  FROM shots";
            query += getConditionQuerry();
            println("query: "+query);
            this.pgsql.query(query);
            while (this.pgsql.next()) {
                int x = this.pgsql.getInt("x") + 250;
                int y = this.pgsql.getInt("y") + 40;
                String name = this.pgsql.getString("name");
                this.grid.addShot(x, y, name);
            }
        }
    }

    String getConditionQuerry() {
        String startQuerry = " WHERE ";
        String quarterQuerry = "";
        String conditionQuerry = "(shot_clock>" + this.shot_clock[0] + " AND shot_clock<" + this.shot_clock[1] + ")";
        for (int i = 0; i < 5; ++i) {
            if (quarters[i]) {
                if (quarterQuerry != "") {
                    quarterQuerry += " OR ";
                }
                quarterQuerry += " period=" + str(i+1);
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
        return startQuerry + conditionQuerry;
    }

}

public class HexDetails  {
	Hexagon currentHex = null;
	// Canvas canvas;
	PShape  hexShape;


	public HexDetails (float r) {
		this.hexShape = createHex(2*r);
	}


	void set_newHex(Hexagon newHex) {
		this.currentHex = newHex;
	}

	void display() {
		if (currentHex != null) {
			pushMatrix();
			translate(currentHex.center[0], currentHex.center[1]);
			fill(0, 0, 255);
			shape(this.hexShape);
			popMatrix();
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

	boolean addShot(int x, int y, String playerName) {
		try {
			float x_scaled = x*this.scale;
			float y_scaled = y*this.scale;
			Hexagon currHex = this.get_hexagon_fromXY(x_scaled, y_scaled);
			currHex.addShot(playerName);
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

public class Hexagon  {
	float[] center;
	PShape hexShape;
	IntDict shots;
	boolean selected = false;
	int maxVal = 30; // brightness

	public Hexagon (PShape hexShape, float[] center) {
		this.hexShape = hexShape;
		this.center = center;
		this.shots = new IntDict();
		this.shots.set("", 0);
	}

	void display() {
		// Calc shot accuracy
		float val = max(shots.valueArray())*255/this.maxVal;
		fill(val);
		pushMatrix();
		translate(this.center[0], this.center[1]);
		// if (this.selected) {
		// 	fill(0, 255, 0);
		// 	scale(2.0);
		// }
		shape(this.hexShape);
		popMatrix();
	}

	void addShot(String playerName) {
		int allNum = 0;
		if (this.shots.hasKey(playerName)) {
			allNum = this.shots.get(playerName) + 1;
		}
		this.shots.set(playerName, allNum);
	}

	// void set_selected(boolean b)  {
	// 	this.selected = b;
	// }

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

public class MadeButton {
    float x, y, width, height;
    boolean on = true;
    String[] labels;
    float padx = 6;
    int currentLabel = 0;
    
    MadeButton ( float xx, float yy, float w, float h, String[] labels ) {
        x = xx; y = yy; width = w; height = h;
        this.labels = labels;
        Interactive.add( this ); // register it with the manager
    }
    
    // called by manager
    
    void mousePressed () {
        on = !on;
    }
    void mouseReleased () {
        on = !on;
        currentLabel += 1;
        currentLabel = currentLabel % 3;
        Interactive.send( this, "labelChanged", labels[currentLabel] );
    }

    void draw () {
        if ( on ) fill( 200 );
        else fill( 100 );
        noStroke();
        rect(x, y, width, height);
        textAlign( LEFT );
        fill( 100 );
        text( labels[currentLabel], x+width+padx, y+height );
        stroke(0);
    }

    boolean isInside ( float mx, float my ) {
        return Interactive.insideRect( x,y,width+padx+textWidth(labels[currentLabel]), height, mx, my );
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
    
    void mouseEntered ()
    {
        on = true;
    }
    
    void mouseExited ()
    {
        on = false;
    }
    
    void mousePressed ( float mx, float my )
    {
        if ( left.isInside( mx, my ) )       activeHandle = left;
        else if ( right.isInside( mx, my ) ) activeHandle = right;
        else                                 activeHandle = null;
        
        pressedX = mx;
        pressedXLeft  = left.x;
        pressedXRight = right.x;
    }

    void mouseReleased() {
        Interactive.send( this, "applayVal");
    }
    
    void mouseDragged ( float mx, float my )
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
    
    void draw ()
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
    
    void draw ()
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
    MadeButton shotMadeBtn;
    MultiSlider clockSlider;

    public Selection (Canvas canvas, Controller controller) {
        this.c = canvas;
        quartersBtn = new CheckBox[4];
        for ( int i = 0; i < 4; ++i ) {
            quartersBtn[i] = new CheckBox( str(i+1), c.x + 20 + i*40, c.y + 90, 10, 10 );
            Interactive.on( quartersBtn[i], "checkboxChenged",  this, "quarterChanged" );
        }

        String labels[] = {"all", "made", "not made"};
        shotMadeBtn = new MadeButton(c.x + 20, c.y + 30, 10, 10, labels);
        Interactive.on( shotMadeBtn, "labelChanged",  this, "madeChanged" );

        clockSlider = new MultiSlider( c.x + 20, c.y+140, c.w-40, 10 );
        Interactive.on( clockSlider, "valueChanged",  this, "clockChanged" );
        Interactive.on( clockSlider, "applayVal",  this, "applay" );
    }

    void display() {
        fill(0, 102, 153);
        textAlign( LEFT );
        text( "SHOTS", c.x + 20, c.y + 20 );
        text( "QUARTERS", c.x + 20, c.y + 80 );
        text( "SHOT CLOCK", c.x + 20, c.y + 130 );
        for (CheckBox b : quartersBtn) {
            b.draw();
        }
    }

    void applay() {
        controller.applaySelection();
    }

    void madeChanged(String label) {
        controller.madeLabel = label;
        controller.applaySelection();
    }

    void clockChanged(float minVal, float maxVal) {
        controller.shot_clock[0] = minVal*24;
        controller.shot_clock[1] = maxVal*24;
        // controller.applaySelection();
    }

    void quarterChanged(String label, boolean checked) {
        int i = int(label);
        controller.quarters[i-1] = checked;
        controller.applaySelection();
    }

}

