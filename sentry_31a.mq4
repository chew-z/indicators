//+------------------------------------------------------------------+
//|                                                   sentry_2a.mq4      |
//| na 10 minut przed pełną godziną wysyła alert informujący, że OK   |
//| teraz powierzam mu inne zadania                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, chew-z"
#property link      "sentry_2a"
#include <TradeContext.mq4>
#include <TradeTools.mqh>
#property indicator_chart_window
#property indicator_buffers 0
//---- alerts

extern bool    quietHours          = true;
extern int     quietStart          = 22;
extern int     quietStop           =  6;
extern int     minute              =  50;
bool           AlertFlag           = false;

int OnInit()    {
    EventSetTimer(60);
    return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason){
    SendNotification("Terminal Deinit reason - " + getDeinitReasonText(reason));
    Print(__FUNCTION__,"_Deinitalization reason code = ", getDeinitReasonText(reason));
    EventKillTimer();
}
void OnTimer() {
  if (quietHours == true || AlertFlag == true) {
    if(Hour() >= quietStart || Hour()< quietStop )
      return; // exit
    if(Minute() > minute)
      AlertFlag = false;
  }
  if (Minute() == minute && AlertFlag == false) {
      SendNotification("Wszystko OK.\n
        PL = " + AccountProfit() + " Marign =" + DoubleToString(AccountMargin(), 2) );
      AlertFlag = true;
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