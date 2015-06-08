//+------------------------------------------------------------------+
//|                                             volatility_2c.mq4    |
//| wysyła alerty związne ze zmiennością                             |
//| (ATR, dzienny zakres etc.)                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, chew-z"
#property link      "volatility_2c"
#include <TradeTools\TradeTools5.mqh>
#include <TradeContext.mq4>
#property indicator_chart_window

//---- indicator parameters

//---- buffers

//---- alerts
input int     AlertCandle    = 0;      // 1 - last fully formed candle, 0 - current forming candle
input int     lookBackRange  = 5;
double true_ATR = 0.0;
int iD = 0;

int OnInit()    {
   AlertEmailSubject = Symbol() + " volatility alert";
   GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), 0);
   // .. and after all this
   if( !IsConnected() )
        Sleep( 5000 );  //wait 5s for establishing connection to trading server
        //Sleep() is automatically passed during testing
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason){
   GlobalVariableDel(StringConcatenate(Symbol(), "_volatility"));
   Print(__FUNCTION__,"_Deinitalization reason code = ", getDeinitReasonText(reason));
   }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])        {

    if (NewDay2() ) {
      GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), 0);
      iD = iBarShift(NULL, PERIOD_D1, Time[AlertCandle], false); // This might be tricky!!!
      true_ATR = f_TrueATR(3, iD);  //compute TrueATR once a day not on every tick
    }
    if (TimeDayOfWeek(TimeLocal()) > 0 && TimeDayOfWeek(TimeLocal()) < 6)
        ProcessAlerts(true_ATR);
    return(0);
}//OnCalculate()

int ProcessAlerts(double TrueATR)   {                                                                                                                         //
AlertText =  "";
//double spread = Ask - Bid;
int semafor = GlobalVariableGet(StringConcatenate(Symbol(), "_volatility"));
int yesterday = AlertCandle + 1;
if ( TimeDayOfWeek( iTime(NULL, PERIOD_D1, iD+yesterday) ) == 0 ) {// if Sunday take previous (Friday's) bar
   yesterday = AlertCandle + 2;
}
// a to? Tutaj potrzeba dobrej funkcji wyboru dni (barów) a nie jakiś sztuczek na kolanie.
H = iHigh(NULL, PERIOD_D1, iHighest(NULL, PERIOD_D1, MODE_HIGH, lookBackRange, iD+yesterday)); // kurwa magic ale chyba dzia³a
L = iLow (NULL, PERIOD_D1, iLowest (NULL, PERIOD_D1, MODE_LOW, lookBackRange, iD+yesterday));

   if (semafor < 7)   { //  7 = 1 + 2 + 4 = all flags set

    if(MathMod(semafor, 2) < 1 && (Low[AlertCandle] < iLow(NULL, PERIOD_D1,iD+yesterday) || High[AlertCandle] > iHigh(NULL, PERIOD_D1,iD+yesterday)) )  {
        AlertText = Symbol() + ", " + TFToStr(Period()) + ": Price action outside yesterday's range. \rPrice = " + DoubleToStr(Bid, 5);
        if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
        if(SendNotifications) SendNotification(AlertText);
        GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), semafor+1);
        return(0);
    }
    if(MathMod(semafor, 4) < 2 && iHigh(NULL, PERIOD_D1, AlertCandle) - iLow(NULL, PERIOD_D1, AlertCandle) > TrueATR )  {
        Print("True ATR = " + TrueATR);
        AlertText = Symbol() + ", " + TFToStr(Period()) + ": Price action outside 3-days ATR. \rPrice = " + DoubleToStr(Bid, 5);
        if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
        if(SendNotifications) SendNotification(AlertText);
        GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), semafor+2);
        return(0);
    }
    if(semafor < 4  && (Low[AlertCandle] < L || High[AlertCandle] > H) )  {
        AlertText = Symbol() + ", " + TFToStr(Period()) + ": Price action outside last days range. \rPrice = " + DoubleToStr(Bid, 5);
        if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
        if(SendNotifications) SendNotification(AlertText);
        GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), semafor+4);
        return(0);
    }

   }
    return(0);
  }

// Może trzeba przenieść to do biblioteki?
double f_TrueATR(int Range, int iDay) { //weź trzy ostatnie sesje odrzucając niedziele
    double sum = 0.0;
    int loop = 0;
    int i = iD+1; //iD should first
    while(loop < Range ) {
        if (TimeDayOfWeek( iTime(NULL, PERIOD_D1, i) ) == 0) {
            Print( "skipping Sunday ", TimeDay( iTime(NULL, PERIOD_D1, i) ) );
            i +=1;
        } else {
            sum += (iHigh(NULL, PERIOD_D1,i) - iLow(NULL, PERIOD_D1,i));
            i +=1;
            loop += 1;
        }
    }
    true_ATR = NormalizeDouble(1.0/Range * sum, Digits);
    return(true_ATR);
}