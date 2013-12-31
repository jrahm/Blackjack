// modules: gee-0.8

public enum Action {
    HIT, DOUBLE_DOWN, SPLIT, STAY
}

public abstract class Agent {
    private int cash ;
    private AgentState current_state ;

    public Agent( int starting_cash ) {
       this.cash = starting_cash ;
    }

    public void setAgentState( AgentState state ) {
        this.current_state = state ;
    }

    public AgentState getAgentState() {
        return current_state ;
    }

    public int getCash() {
        return cash ;
    }

    public void setCash( int cash ) {
        this.cash = cash ;
    }

    public bool commitOneAction( Game game ) {
        Action action = this.getActionForGame( game ) ;
        return this.current_state.applyAction( game, action, this ) ;
    }

    public void playFullHand( Game game ) {
        while( this.current_state.hasMoreHands() ) {
            while( ! commitOneAction( game ) ) ;
        }
    }

    public void placeStartingBet() {
        uint bet = getStartingBet() ;

        if( bet > cash ) {
            bet = cash ;
        }

        current_state.getCurrentHand().setBet( bet ) ;
        cash -= (int)bet ;
    }

    public abstract uint getStartingBet() ;

    public abstract Action getActionForGame( Game game ) ;

    public virtual void winLosePushCallback( Hand dealer, int winLose ) {}
}

