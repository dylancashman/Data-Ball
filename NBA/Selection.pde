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
        text( "OFFENSE", c.x + 20, c.y + 235);
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

    void shotMadeOn() {
        for (MadeButton b : shotSelectionBtns) {
            b.turnOff();
        }
        shotMadeBtn.turnOn();
        madeChanged("made");
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

    void hawksOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        hawksBtn.turnOn();
        teamChanged("Atlanta Hawks");
    }
    void celticsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        celticsBtn.turnOn();
        teamChanged("Boston Celtics");
    }
    void netsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        netsBtn.turnOn();
        teamChanged("Brooklyn Nets");
    }
    void bobcatsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        bobcatsBtn.turnOn();
        teamChanged("Charlotte Bobcats");
    }
    void bullsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        bullsBtn.turnOn();
        teamChanged("Chicago Bulls");
    }
    void cavsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        cavsBtn.turnOn();
        teamChanged("Cleveland Cavaliers");
    }
    void mavsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        mavsBtn.turnOn();
        teamChanged("Dallas Mavericks");
    }
    void nuggetsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        nuggetsBtn.turnOn();
        teamChanged("Denver Nuggets");
    }
    void pistonsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        pistonsBtn.turnOn();
        teamChanged("Detroit Pistons");
    }
    void warriorsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        warriorsBtn.turnOn();
        teamChanged("Golden State Warriors");
    }
    void rocketsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        rocketsBtn.turnOn();
        teamChanged("Houston Rockets");
    }
    void pacersOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        pacersBtn.turnOn();
        teamChanged("Indiana Pacers");
    }
    void clippersOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        clippersBtn.turnOn();
        teamChanged("Los Angeles Clippers");
    }
    void lakersOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        lakersBtn.turnOn();
        teamChanged("Los Angeles Lakers");
    }
    void grizzliesOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        grizzliesBtn.turnOn();
        teamChanged("Memphis Grizzlies");
    }
    void heatOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        heatBtn.turnOn();
        teamChanged("Miami Heat");
    }
    void bucksOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        bucksBtn.turnOn();
        teamChanged("Milwaukee Bucks");
    }
    void twolvesOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        twolvesBtn.turnOn();
        teamChanged("Minnesota Timberwolves");
    }
    void pelicansOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        pelicansBtn.turnOn();
        teamChanged("New Orleans Pelicans");
    }
    void knicksOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        knicksBtn.turnOn();
        teamChanged("New York Knicks");
    }
    void thunderOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        thunderBtn.turnOn();
        teamChanged("Oklahoma City Thunder");
    }
    void magicOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        magicBtn.turnOn();
        teamChanged("Orlando Magic");
    }
    void sixersOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        sixersBtn.turnOn();
        teamChanged("Philadelphia 76ers");
    }
    void sunsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        sunsBtn.turnOn();
        teamChanged("Phoenix Suns");
    }
    void blazersOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        blazersBtn.turnOn();
        teamChanged("Portland Trail Blazers");
    }
    void kingsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        kingsBtn.turnOn();
        teamChanged("Sacramento Kings");
    }
    void spursOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        spursBtn.turnOn();
        teamChanged("San Antonio Spurs");
    }
    void raptorsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        raptorsBtn.turnOn();
        teamChanged("Toronto Raptors");
    }
    void jazzOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        jazzBtn.turnOn();
        teamChanged("Utah Jazz");
    }
    void wizardsOn() {
        for (MadeButton b : teamSelectBtns) {
            b.turnOff();
        }
        wizardsBtn.turnOn();
        teamChanged("Washington Wizards");
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
