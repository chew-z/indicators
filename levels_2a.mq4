//+------------------------------------------------------------------+
//|                                                   levels_2a.mq4        |
//| rysuje dwa zadane poziomy wsparcia i dwa oporu  |
//| dodatkowo wysyła alerty                                         |
//| bardziej wyrafinowane alerty                                   |  
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
extern double H2 = 1.31;
extern double H1 = 1.30;
extern double L1 = 1.29;
extern double L2 = 1.28;
//---- buffers
double High2Buffer[];
double High1Buffer[];
double Low1Buffer[];
double Low2Buffer[];
//---- alerts
extern int     AlertCandle              = 0;      // 1 - last fully formed candle, 0 - current forming candle
extern bool    ShowChartAlerts    = false;   // Show allerts in MQL 
datetime       LastAlertTime         = -999999;
string         AlertTextCrossUp       = " cross UP";
string         AlertTextCrossDown  = " cross DOWN";

int init()
  {
   SetIndexBuffer(3,High2Buffer);
   SetIndexBuffer(2,High1Buffer);
   SetIndexBuffer(1,Low1Buffer); 
   SetIndexBuffer(0,Low2Buffer);
   SetIndexStyle (3,DRAW_LINE,STYLE_DASHDOTDOT, 1);
   SetIndexStyle (2,DRAW_LINE,STYLE_DASHDOT, 1);
   SetIndexStyle (1,DRAW_LINE,STYLE_DASHDOT, 1);
   SetIndexStyle (0,DRAW_LINE,STYLE_DASHDOTDOT, 1);
   SetIndexDrawBegin(3,0);
   SetIndexDrawBegin(2,0);
   SetIndexDrawBegin(1,0);
   SetIndexDrawBegin(0,0);
   return(0);
  }

int start()    { 
   int i,                       // indeksy
       Counted_bars;            // Number of counted bars
   
   Counted_bars = IndicatorCounted();  // Number of counted bars
   i = Bars-Counted_bars-1;            // Index of the first uncounted
while(i>=0)    {                  // Loop for uncounted bars
   High2Buffer[i] = H2;
   High1Buffer[i] = H1;
   Low1Buffer[i] = L1;
   Low2Buffer[i] = L2;
   i--; 
} // while
   ProcessMoreAlerts(); 
   return(0); // exit
}


int ProcessMoreAlerts()   {                                                                                                                         //
string AlertText = "";   
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
   }
    return(0); 
  }                                                                                                      
                                                                                                                        