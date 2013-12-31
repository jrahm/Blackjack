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
