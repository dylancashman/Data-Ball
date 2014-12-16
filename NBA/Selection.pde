public class Selection {
    Canvas c;
    CheckBox[] quartersBtn;
    ArrayList<MadeButton> shotSelectionBtns;
    MadeButton allBtn;
    MadeButton shotMissedBtn;
    ArrayList<MadeButton> displayTypeBtns;
    MadeButton frequencyBtn;
    MadeButton fgBtn;
    MadeButton efgBtn;
    ArrayList<MadeButton> teamSelectBtns;
    MadeButton allTeamsBtn;
    MadeButton rocketsBtn;
    MadeButton celticsBtn;
    MadeButton grizzliesBtn;
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

        allBtn = new MadeButton(c.x + 20, c.y + 30, 10, 10, "All", true, this);
        Interactive.on( allBtn, "All", this, "allOn");
        shotMissedBtn = new MadeButton(c.x + 80, c.y + 30, 10, 10, "Not Made", false, this);
        Interactive.on( shotMissedBtn, "Not Made", this, "shotNotMadeOn");
        
        shotSelectionBtns = new ArrayList<MadeButton>();
        shotSelectionBtns.add(allBtn);
        shotSelectionBtns.add(shotMissedBtn);

        frequencyBtn = new MadeButton(c.x + 20, c.y + 90, 10, 10, "Frequency", true, this);
        Interactive.on( frequencyBtn, "Frequency", this, "frequencyOn");

        fgBtn = new MadeButton(c.x + 120, c.y + 90, 10, 10, "FG%", false, this);
        Interactive.on( fgBtn, "FG%", this, "fgOn");

        efgBtn = new MadeButton(c.x + 220, c.y + 90, 10, 10, "eFG%", false, this);
        Interactive.on( efgBtn, "eFG%", this, "efgOn");
        
        displayTypeBtns = new ArrayList<MadeButton>();
        displayTypeBtns.add(frequencyBtn);
        displayTypeBtns.add(fgBtn);
        displayTypeBtns.add(efgBtn);

        allTeamsBtn = new MadeButton(c.x + 20, c.y + 240, 10, 10, "All Teams", true, this);
        Interactive.on( allTeamsBtn, "All Teams", this, "allTeamsOn");
        rocketsBtn = new MadeButton(c.x + 80, c.y + 240, 10, 10, "HOU", false, this);
        Interactive.on( rocketsBtn, "HOU", this, "rocketsOn");
        celticsBtn = new MadeButton(c.x + 140, c.y + 240, 10, 10, "BOS", false, this);
        Interactive.on( celticsBtn, "BOS", this, "celticsOn");
        grizzliesBtn = new MadeButton(c.x + 200, c.y + 240, 10, 10, "MEM", false, this);
        Interactive.on( grizzliesBtn, "MEM", this, "grizzliesOn");

        teamSelectBtns = new ArrayList<MadeButton>();
        teamSelectBtns.add(allTeamsBtn);
        teamSelectBtns.add(rocketsBtn);
        teamSelectBtns.add(celticsBtn);
        teamSelectBtns.add(grizzliesBtn);

        clockSlider = new MultiSlider( c.x + 20, c.y+200, c.w-40, 10 );
        Interactive.on( clockSlider, "valueChanged",  this, "clockChanged" );
        Interactive.on( clockSlider, "applayVal",  this, "applay" );
    }

    void display() {
        fill(0, 102, 153);
        textAlign( LEFT );
        text( "SHOTS", c.x + 20, c.y + 20 );
        text( "DISPLAY TYPE", c.x + 20, c.y + 80 );
        text( "QUARTERS", c.x + 20, c.y + 140 );
        text( "SHOT CLOCK", c.x + 20, c.y + 190 );
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

    void teamChanged(String label) {
        controller.teamLabel = label;
        controller.applaySelection();
    }

    void notifyFromButton(String label) {
        println(" notify from button called with label " + label);
        if (label.equals("All")) {
            allOn();
        } else if (label.equals("Not Made")) {
            shotMissedOn();
        } else if (label.equals("Frequency")) {
            frequencyOn();
        } else if (label.equals("FG%")) {
            fgOn();
        } else if (label.equals("eFG%")) {
            efgOn();
        } else if (label.equals("All Teams")) {
            allTeamsOn();
        } else if (label.equals("HOU")) {
            rocketsOn();
        } else if (label.equals("BOS")) {
            celticsOn();
        } else if (label.equals("MEM")) {
            grizzliesOn();
        }
    }

    void allOn() {
        for (MadeButton b : shotSelectionBtns) {
            b.turnOff();
        }
        allBtn.turnOn();
        madeChanged("all");
    }

    void shotMissedOn() {
        for (MadeButton b : shotSelectionBtns) {
            b.turnOff();
        }
        shotMissedBtn.turnOn();
        madeChanged("not made");
    }

    void frequencyOn() {
        for (MadeButton b : displayTypeBtns) {
            b.turnOff();
        }
        frequencyBtn.turnOn();
        controller.setDisplayMode("frequency");
    }

    void fgOn() {
        for (MadeButton b : displayTypeBtns) {
            b.turnOff();
        }
        fgBtn.turnOn();
        controller.setDisplayMode("fg");
    }

    void efgOn() {
        for (MadeButton b : displayTypeBtns) {
            b.turnOff();
        }
        efgBtn.turnOn();
        controller.setDisplayMode("efg");
    }

    void allTeamsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        allTeamsBtn.turnOn();
        teamChanged("all");
    }

    void rocketsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        rocketsBtn.turnOn();
        teamChanged("Houston Rockets");
    }

    void celticsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        celticsBtn.turnOn();
        teamChanged("Boston Celtics");
    }

    void grizzliesOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        grizzliesBtn.turnOn();
        teamChanged("Memphis Grizzlies");
    }

    void clockChanged(float minVal, float maxVal) {
        controller.shot_clock[0] = minVal*24;
        controller.shot_clock[1] = maxVal*24;
        // controller.applaySelection();
    }

    void quarterChanged(String label, boolean checked) {
        if (label == "OT") {
            controller.quarters[4] = checked;
            controller.applaySelection();
        } else {
            int i = int(label);
            controller.quarters[i-1] = checked;
            controller.applaySelection();
        }
    }

}
