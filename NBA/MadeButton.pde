public class MadeButton {
    float x, y, width, height;
    boolean on = true;
    String label;
    float padx = 6;
    int currentLabel = 0;
    Selection selection;
    
    MadeButton ( float xx, float yy, float w, float h, String label, boolean selected, Selection my_selection) {
        x = xx; y = yy; width = w; height = h;
        this.on = selected;
        this.label = label;
        Interactive.add( this ); // register it with the manager
        this.selection = my_selection;
    }

    void turnOn() {
        this.on = true;
    }

    void turnOff() {
        this.on = false;
    }
    
    // called by manager
    
    void mousePressed () {
        println("MOUSE PRESSED in " + label);
        // on = !on;
    }
    void mouseReleased () {
        // println("MOUSE RELEASED in " + label);
        // Interactive.send( this, label);
        selection.notifyFromButton(label);
    }

    void draw () {
        if ( on ) fill( 100 );
        else fill( 200 );
        noStroke();
        ellipse(x, y, width, height);
        textAlign( CENTER );
        fill( 100 );
        text( label, x+width+padx, y+height );
        stroke(0);
    }

    boolean isInside ( float mx, float my ) {
        return Interactive.insideRect( x,y,width+padx+textWidth(label), height, mx, my );
    }
}