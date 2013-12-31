// include: src/Agent.vala
// modules: gee-0.8

using Gee ;

public class HumanAgent : Agent {
    public HumanAgent( int starting_cash ) {
        base(starting_cash) ;
    }

    public override uint getStartingBet() {
        int ret = 0 ;
        do {
            stdout.printf("(%d) Place your bet: ", getCash()) ;
            string? str = stdin.read_line() ;
            ret = int.parse( str ) ;
        } while( ret == 0 ) ;
        return (uint)ret ;
    }

    private void printGameState( Game game ) {
        stdout.printf("Cash: %d\n", getCash() ) ;
        stdout.printf("Dealer card: %s\n", cardToStr(game.getDealerCard()) ) ;
        Hand hand = this.getAgentState().getCurrentHand() ;
        stdout.printf("Current Hand:%s -- %u\n", hand.toString(), hand.getCardSum());
        stdout.printf("Enter Action (Hit,Stay,Double,Split): ") ;
    }

    public override Action getActionForGame( Game game ) {
        do {
            printGameState( game ) ;
            string? action = stdin.read_line() ;

            if( action == "Hit" ) {
                return Action.HIT ;
            } else if( action == "Stay" ) {
                return Action.STAY ;
            } else if( action == "Double" ) {
                return Action.DOUBLE_DOWN ;
            } else if( action == "Split" ) {
                return Action.SPLIT ;
            }
        } while ( true ) ;
    }

    public override void winLosePushCallback( Hand dealer, int winLose ) {
        stdout.printf( "Dealer Hand:%s -- %u\n", dealer.toString(), dealer.getCardSum() );

        if( winLose > 0 ) {
            stdout.printf( "Win!\n" );
        } else if( winLose == 0 ) {
            stdout.printf( "Push\n" );
        } else if( winLose == -1 ) {
            stdout.printf( "Lose\n" );
        } else if( winLose == -2 ) {
            stdout.printf( "Lose: Bust\n" );
        }

        stdout.printf( "---------------------------------------------------------------\n" );
    }

    public static void main( string[] args ) {
        stdout.printf("Blackjack! -- 0.0.1\n") ;
        HumanAgent agent = new HumanAgent( 5000 ) ;
        Agent[] agents = new Agent[]{agent} ;

        Game game = new Game( agents ) ;
        game.playNRounds( 100000 ) ;
    }
}
