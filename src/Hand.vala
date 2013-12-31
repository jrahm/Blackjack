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
