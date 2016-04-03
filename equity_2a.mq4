//+------------------------------------------------------------------+
//|                                                   equity_1a.mq4   |
//| Co 5 minut zapisuje do pliku wartość Equity i PL                  |
//| w celu późniejszej analizy                                        |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, chew-z"
#property link      "equity_1a"
#include <TradeContext.mq4>
#include <TradeTools\TradeTools5.mqh>
#property indicator_chart_window
#property indicator_buffers 0


extern int    Equity_Interval     = 300;
static int    handle              = 0;
static int    i                   = 0;
double eq                         = 0.0;
static double max_eq              = 0.0;

int OnInit()    {
        EventSetTimer(Equity_Interval);
        GlobalVariableSet(StringConcatenate(Symbol(), "_equity"), 0);
        handle = FileOpen("Equity.csv", FILE_CSV|FILE_READ|FILE_WRITE, ';');
        max_eq = AccountEquity();
        return(INIT_SUCCEEDED);
    }
void OnDeinit(const int reason){
        FileClose(handle);
        GlobalVariableDel(StringConcatenate(Symbol(), "_equity"));
        Print(__FUNCTION__,"_Deinitalization reason code = ", getDeinitReasonText(reason));
        EventKillTimer();
}
void OnTimer() {
     i += 1;
     if ( i % 12 == 0 ) { //Once in an hour save to disk
        FileFlush( handle );
        GlobalVariableSet(StringConcatenate(Symbol(), "_equity"), 0);
        //It keeps file locked so perhaps I should change the logic. But works OK.
        }
     datetime t = TimeLocal();
     eq = AccountEquity();
     if (NewDay2()) {
        max_eq = eq;
        GlobalVariableSet(StringConcatenate(Symbol(), "_equity"), 0);
        }
     if(FileSeek(handle, 0, SEEK_END)) {
        FileWrite(handle, i, t, eq, AccountProfit());
        }
     int semafor = GlobalVariableGet(StringConcatenate(Symbol(), "_volatility"));
     if (eq > max_eq)
        max_eq = eq;
     if (eq > 0.50 * max_eq && eq <= 0.90 * max_eq && semafor < 5 ) {
        AlertEmailSubject = "EQUITY DANGER";
        AlertText = "Losing so much money that quickly is self-destructive! You have to get out!!! NOW!";
        SendMail(AlertEmailSubject, AlertText);
        SendNotification(AlertText);
        GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), semafor + 1);
        return;
        }
        if (eq <= 0.95 * max_eq && eq > 0.90 * max_eq && semafor < 4 ) {
        AlertEmailSubject = "EQUITY ALERT";
        AlertText = "You are losing too much money too quickly. Equity droped more then 5% from maximum.\nGet out! Fight another day.";
        SendMail(AlertEmailSubject, AlertText);
        //SendNotification(AlertText);
        GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), semafor + 1);
        return;
        }
        if (eq <= 0.98 * max_eq && eq > 0.95 * max_eq && semafor < 3 ) {
        AlertEmailSubject = "EQUITY WARNING";
        AlertText = "You are losing money. Equity droped more then 2% from maximum. Can you manage?";
        SendMail(AlertEmailSubject, AlertText);
        //SendNotification(AlertText);
        GlobalVariableSet(StringConcatenate(Symbol(), "_volatility"), semafor + 1);
        return;
        }
    return; // normal exit
}
// OnCalculate() is empty and not used
int OnCalculate(const int rates_total,
                                const int prev_calculated,
                                const datetime &time[],
                                const double &open[],
                                const double &high[],
                                const double &low[],
                                const double &close[],
                                const long &tick_volume[],
                                const long &volume[],
                                const int &spread[])
    {
     return(rates_total);
    }