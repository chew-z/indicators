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


extern int    Equity_Interval     =  300;
static int    handle              = 0;
static int    i                   = 0;

int OnInit()    {
        EventSetTimer(Equity_Interval);
        handle = FileOpen("Equity.csv", FILE_CSV|FILE_READ|FILE_WRITE, ',');
        return(INIT_SUCCEEDED);
    }
void OnDeinit(const int reason){
        FileClose(handle);
        Print(__FUNCTION__,"_Deinitalization reason code = ", getDeinitReasonText(reason));
        EventKillTimer();
}
void OnTimer() {
     i += 1;
     datetime t = TimeLocal();
     if(FileSeek(handle, 0, SEEK_END)) {
            //Print("appending to file");
            FileWrite(handle, i, t, AccountEquity(), AccountProfit());
     }
    return; // exit
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