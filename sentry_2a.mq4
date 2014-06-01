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

void OnInit()    {
    GlobalVariableSet("sentry_2a", 0);
    Print("Account credit ", AccountCredit());
    Print("Account profit ", AccountProfit());
    Print("Account margin ", AccountMargin());
    Print("Account free margin = ", AccountFreeMargin());
    Print("Account margin mode ", AccountFreeMarginMode());
    Print("Account equity = ", AccountEquity());
    Print("Account balance = ", AccountBalance());
  }
void OnDeinit(const int reason){
    SendNotification("Terminal - Uninitalization reason code = " + reason);
    Print(__FUNCTION__,"_Uninitalization reason code = ", reason);
    GlobalVariableDel("sentry_2a");
}
int OnCalculate(
                const int rates_total,    // number of available bars in history at the current tick
                const int prev_calculated,// number of bars, calculated at previous tick
                const int begin,          // index of the first bar
                const double &price[]     // price array for the calculation 
                )             { 
  string AlertText = "Wszystko OK";

  if (NewDay() )
    GlobalVariableSet("sentry_2a", 0);

  if (GlobalVariableGet("sentry_2a") == 0 && AccountFreeMargin() < 20000.00) {
    SendNotification("ALERT - Account free margin is low!"+ AccountFreeMargin());
    GlobalVariableSet("sentry_2a", 1);
  }

  if (quietHours == true || AlertFlag == true) {
    if(Hour() >= quietStart || Hour()< quietStop )
      return rates_total; // exit
    if(Minute() > minute)
      AlertFlag = false;
  }

  if (Minute() == minute && AlertFlag == false) {  
      AlertText = "Wszystko OK";
      SendNotification(AlertText);
      AlertFlag = true;
  }
  return rates_total; // exit
}   
 