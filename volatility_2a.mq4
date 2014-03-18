//+------------------------------------------------------------------+
//|                                                   volatility_2a.mq4    |
//| wysyła alerty związne ze zmiennością                     |
//| (ATR, dzienny zakres etc.)                                       |  
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, chew-z"
#property link      "levels_2a"
#include <TradeTools.mqh>
#include <TradeContext.mq4>
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red      // Color of the High line 2
#property indicator_color2 Red      // Color of the High line 1
#property indicator_color3 Green    // Color of the Low line 1
#property indicator_color4 Green    // Color of the Low line 2
//---- indicator parameters
extern int lookBackRange = 3;
//---- buffers

//---- alerts
extern int     AlertCandle              = 0;      // 1 - last fully formed candle, 0 - current forming candle
extern bool    ShowChartAlerts    = false;   // Show allerts in MQL 
datetime       LastAlertTime         = -999999;
string         AlertTextCrossUp       = " cross UP";
string         AlertTextCrossDown  = " cross DOWN";

int init()
  {
  AlertEmailSubject = Symbol() + " volatility alert"; 
   return(0);
  }

int start()    { 
   int i,                       // indeksy
       Counted_bars;            // Number of counted bars
   
   Counted_bars = IndicatorCounted();  // Number of counted bars
   i = Bars-Counted_bars-1;            // Index of the first uncounted
while(i>=0)    {                  // Loop for uncounted bars

   i--; 
} // while
   ProcessMoreAlerts(); 
   return(0); // exit
}


int ProcessMoreAlerts()   {                                                                                                                         //
string AlertText =  "";
   if (AlertCandle >= 0  &&  Time[0] > LastAlertTime)   { // Time[0] = Open time. So one alert per new bar
    if( Low[AlertCandle] < iLow(NULL, PERIOD_D1, 1) || High[AlertCandle] > iHigh(NULL, PERIOD_D1, 1) )  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": Price action outside yesterday's range. \rPrice = " + DoubleToStr(Bid, 5);
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }
    if( iHigh(NULL, PERIOD_D1, AlertCandle) - iLow(NULL, PERIOD_D1, AlertCandle) >  iATR(NULL,PERIOD_D1,3,1) )  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": Price action outside 3-days ATR. \rPrice = " + DoubleToStr(Bid, 5);
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }
    H = iHigh(NULL, PERIOD_D1, iHighest(NULL,PERIOD_D1,MODE_HIGH,lookBackRange,1)); // kurwa magic ale chyba dzia³a
    L = iLow (NULL, PERIOD_D1, iLowest (NULL,PERIOD_D1,MODE_LOW,lookBackRange,1));
    if( Low[AlertCandle] < L || High[AlertCandle] > H)  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": Price action outside last days range. \rPrice = " + DoubleToStr(Bid, 5);
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }
   }
    return(0); 
  }                                                                                                      
                                                                                                                        