// include: Agent.vala

public class AgentState {
    private int hand_index = 0 ;
    private List<Hand> hands ;

    /**
     * Creates a new AgentState with
     */
    public AgentState( uint card1, uint card2, uint bet=0 ) {
        hands = new List<Hand>();
        hands.append( new Hand( card1, card2, bet ) ) ;
    }

    /**
     * @return The current Hand that the state is on
     */
    public Hand getCurrentHand() {
        return hands.nth_data( hand_index ) ;
    }

    public List<Hand> getHands() {
        return hands.copy() ;
    }

    /**
     * Applys an action to the hand that is currently being
     * played in this Round
     *
     * @param game   The game that contains the dealer cards
     * @param action The action the agent chose
     * @param agent  The agent, used to deduct cash for doubledown or split
     *
     * @return True if the action applied ended the hand. E.g if the
     * Hit busted or a stay was issued.
     *
     */
    public bool applyAction( Game game, Action action, Agent agent ) {
        /* Make sure we have a hand to play */
        if( ! this.hasMoreHands() ) {
            /* If we don't, then just return done */
            return true ;
        }

        Hand cur = getCurrentHand() ;

        switch( action ) {
        case Action.HIT:
            uint card = game.getDeck().draw() ;
            cur.addCard( card ) ;

            // stdout.printf( "[DEBUG] cur.isBusted()? %s\n", cur.isBusted()?"true":"false" );
            if( cur.isBusted() ) ++ hand_index ;
            return cur.isBusted() ;

        case Action.SPLIT:
            try {
                Hand new_hand ;
                hands.append(new_hand = cur.split());
                int cash = agent.getCash() ;
                if( cash < cur.getBet() ) {
                    new_hand.setBet( cash );
                    agent.setCash( 0 );
                } else {
                    new_hand.setBet( cur.getBet() ) ;
                    agent.setCash( cash - (int)cur.getBet() );
                }
            } catch ( IllegalActionError e ) {
                ++ hand_index ;
                return true ;
            }
            break ;

        case Action.STAY:
            ++ hand_index ;
            return true ;

        case Action.DOUBLE_DOWN:
            int cash = agent.getCash() ;
            if( cash < cur.getBet() ) {
                cur.setBet( cur.getBet() + cash ) ;
                agent.setCash( 0 ) ;
            } else {
                uint bet = cur.getBet() ;
                cur.setBet( bet * 2 ) ;
                agent.setCash( cash - (int)bet );
            }
            uint card = game.getDeck().draw() ;
            cur.addCard( card ) ;
            ++ hand_index ;
            return true ;
        }

        return false ;
    }

    /**
     * @return true if there are more hands for this agent to play
     */
    public bool hasMoreHands() {
        // stdout.printf("[DEBUG] Has more hands %u < %u\n", this.hand_index, this.hands.length()) ;
        return this.hand_index < this.hands.length() ;
    }

}
