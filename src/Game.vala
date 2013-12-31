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
