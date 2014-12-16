public class Controller  {
    PostgreSQL pgsql;
    HexGrid grid;
    String madeLabel = "all";
    String teamLabel = "all";
    boolean[] quarters = {false, false, false, false, false};
    float[] shot_clock = {.0, 24.0};
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

    void setDisplayMode(String mode) {
        this.displayMode = mode;
        grid.setDisplayMode(mode);
    }

    void applaySelection() {
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

    String getConditionQuerry() {
        String startQuerry = " WHERE 1=1 AND ";
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
        if (teamLabel != "all") {
            conditionQuerry += " AND team_name = '" + teamLabel + "'";
        }
        return startQuerry + conditionQuerry;
    }

    int gettotalshotsMade() {
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

    int gettotalshotsMissed() {
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

    int gettotalthreesMade() {
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

    int gettotalthreesMissed() {
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

    int gettotaltwosMade() {
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

    int gettotaltwosMissed() {
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