// Agent vala

public errordomain IllegalActionError {
    ILLEGAL_ACTION
}


public string cardToStr( uint card ) {
    if( card == 1 ) {
        return "A" ;
    } else if( card == 11 ) {
        return "J" ;
    } else if( card == 12 ) {
        return "Q" ;
    } else if( card == 13 ) {
        return "K" ;
    } else  {
        return "%u".printf(card) ;
    }
}

public class Hand {
    private uint bet ;
    private List<uint> cards ;

    private Hand.single( uint card, uint bet=0 ) {
        this.bet = bet ;
        cards = new List<uint>() ;
        cards.append( card ) ;
    }

    public Hand( uint card1, uint card2, uint bet ) {
        this.single( card1, bet ) ;
        cards.append( card2 ) ;
    }

    public uint getBet() {
        return bet ;
    }

    public void setBet( uint newbet ) {
        this.bet = newbet ;
    }

    public uint getCardSum() {
        uint tot = 0 ;
        int soft = 0 ;
        foreach ( uint i in cards ) {
            if( i == 1 ) {
                soft ++ ;
                tot += 11 ;
            } else if( i >= 10 ) {
                tot += 10 ;
            } else {
                tot += i ;
            }
        }

        /* if the score is above 21 but that includes aces,
           subtract the aces */
        while( soft > 0 && tot > 21 ) {
            tot -= 10 ;
            -- soft ;
        }

        return tot ;
    }

    public uint getCard( int which ) {
        return cards.nth_data( which ) ;
    }

    public uint getNumberOfCards() {
        uint size =  cards.length() ;
        return size ;
    }

    public void addCard( uint card ) {
        cards.append( card );
    }

    public bool canSplit() {
        return getNumberOfCards() == 2 && cards.nth_data(0) == cards.nth_data(1) ;
    }

    public bool isBusted() {
        return getCardSum() > 21 ;
    }

    public Hand split() throws IllegalActionError {
        if ( ! canSplit() ) {
            throw new IllegalActionError.ILLEGAL_ACTION("Cannot Split Hand") ;
        } else {
            uint card = this.cards.nth_data(1) ;
            this.cards.remove_link( this.cards.nth(1) ) ;           
            return new Hand.single( card ) ;
        }
    }

    public uint getNumberOfAces() {
        int count = 0;
        foreach ( uint i in cards ) {
            if( i == 1 ) {
                ++ count ;
            }
        }
        return count ;
    }

    public string toString() {
        var builder = new StringBuilder() ;
        for( int i = 0 ; i < this.getNumberOfCards() ; ++ i ) {
            builder.append(" %s".printf(cardToStr(this.getCard(i)))) ;
        }
        return builder.str ;
    }
}

public enum Action {
    HIT, DOUBLE_DOWN, SPLIT, STAY
}

public class Deck {
    private uint next = 0 ;
    private int deck_count = 0 ;
    private uint[] cards ;

    public Deck( int ndecks = 1 ) {
        cards = new uint[ ndecks * 52 ] ;

        for ( int i = 0 ; i < cards.length ; ) {
            for ( int j = 0 ; j < 13 ; j ++, i++) {
                cards[i] = j + 1 ;
            }
        }

        shuffle() ;
    }

    public void shuffle() {
        for ( int i = 0 ; i < cards.length ; ++ i ) {
            int rand = Random.int_range( 0, cards.length-1 ) ;
            uint temp = cards[rand] ;
            cards[rand] = cards[i] ;
            cards[i] = temp ;
        }
    }

    public int getDeckCount() {
        return deck_count ;
    }

    public uint draw() {
        if ( next >= cards.length ) {
            next = 0 ;
            shuffle() ;
        }

        uint next = cards[next ++] ;
        if( next > 9 ) deck_count -- ;
        else if( next < 7 ) deck_count ++ ;
        return next ;
    }
}

public class Game {
    private Deck deck ;
    private Hand dealer ;

    private List<Agent> agents ;

    public Game( Agent[] agents ) {
        this.agents = new List<Agent> () ;
        foreach( Agent a in agents ) {
            this.agents.prepend( a ) ;
        }

        deck = new Deck( 5 ) ;
    }

    public void playNRounds( uint nrounds ) {
        for ( int i = 0 ; i < nrounds ; ++ i ) {
            // place bets and deal
            agents.foreach( (agent) => {
                agent.setAgentState( new AgentState( deck.draw(), deck.draw() ) ) ;
                agent.placeStartingBet() ;
            }) ;

            dealer = new Hand( deck.draw(), deck.draw(), 0 ) ;

            // play the hands
            agents.foreach( (agent) => {
                agent.playFullHand( this ) ;
            }) ;

            playDealerHand() ;

            bool busted = dealer.isBusted() ;
            uint dealerSum = dealer.getCardSum() ;
            agents.foreach( (agent) => {
                agent.getAgentState().getHands().foreach( (hand) => {
                    if( !hand.isBusted() ) {
                        int bet = (int)hand.getBet() ;
                        if (busted || hand.getCardSum() > dealerSum) {
                            agent.setCash( agent.getCash() + bet * 2 ) ;
                            agent.winLosePushCallback( dealer, 1 ) ;
                        } else if ( hand.getCardSum() == dealerSum ) {
                            agent.setCash( agent.getCash() + bet ) ;
                            agent.winLosePushCallback( dealer, 0 ) ;
                        } else {
                            agent.winLosePushCallback( dealer, -1 ) ;
                        }
                    } else {
                        agent.winLosePushCallback( dealer, -2 ) ;
                    }
                }) ;
            } ) ;
        }
    }

    public void playDealerHand() {
        while( dealer.getCardSum() < 17 ) {
            dealer.addCard( deck.draw() ) ;
        }
    }

    public Deck getDeck() {
        return deck ;
    }

    public uint getDealerCard() {
        return dealer.getCard( 0 ) ;
    }

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
