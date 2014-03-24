//+------------------------------------------------------------------+
//|                                                   trendline_a.mq4     |
//| rysuje linie trendu                                                    |
//| dodatkowo wysyła alerty                                         |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, chew-z"
#property link      "trendline_a"
#include <TradeTools.mqh>
#include <TradeContext.mq4>
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red      // Color of the High trendline 
#property indicator_color2 Green   // Color of the High trendline 
//---- indicator parameters
//---- buffers
double Low1Buffer[];
double High1Buffer[];
//---- alerts
extern int     AlertCandle              = 0;      // 1 - last fully formed candle, 0 - current forming candle
datetime       LastAlertTime         = -999999;
string         AlertTextCrossUp       = " trendline cross UP";
string         AlertTextCrossDown  = " trendline cross DOWN";

int init()    {
   AlertEmailSubject = Symbol() + " trendline alert"; 
   GlobalVariableSet(StringConcatenate(Symbol(), "_trendline"), 0);

   SetIndexBuffer(1,Low1Buffer);
   SetIndexBuffer(0,High1Buffer);

   SetIndexStyle (1,DRAW_LINE,STYLE_DASHDOT, 1);
   SetIndexStyle (0,DRAW_LINE,STYLE_DASHDOTDOT, 1);

   SetIndexDrawBegin(1,0);
   SetIndexDrawBegin(0,0);
   return(0);
  }
int deinit()    {
   GlobalVariableDel(StringConcatenate(Symbol(), "_trendline"));
   return(0);
   }
int start()    { 
     int i,                             // indeksy
        Counted_bars;         // Number of counted bars     
     Counted_bars = IndicatorCounted();  // Number of counted bars
     i = Bars-Counted_bars-1;                   // Index of the first uncounted
     int max1 = FindPeak();
     int max2 = Find2Peak(max1);
     int min1 = FindValley();
     int min2 = Find2Valley(min1);
     double deltaYh = (High[max1]-High[max2]) / (max1 - max2);    // delta Y High
     double deltaYl = (Low[min2]-Low[min1]) / (min1 - min2);          // delta Y Low

     while(i>=0)    {                                      // Loop for uncounted bars  
        if(i <= rangeX) {
          High1Buffer[i]  = High[max1] - (max1 - i) * deltaYh;
          Low1Buffer[i]   = Low[min1] + (min1 - i) * deltaYl;
        }
        i--; 
      } // while
    ProcessAlerts();
  return(0); // exit
}

int ProcessAlerts()   {                                                                                                                         //
string AlertText = "";
H = High1Buffer[AlertCandle];
L = Low1Buffer[AlertCandle];
  if (AlertCandle >= 0  &&  Time[0] > LastAlertTime)   { // Time[0] = Open time. So one alert per new bar
    // Upper bands
    // === Alert processing for crossover UP (indicator line crosses ABOVE signal line)
   if (Close[AlertCandle] > High1Buffer[AlertCandle]  &&  Close[AlertCandle+1] <= High1Buffer[AlertCandle+1])  { 
      AlertText = Symbol() + "," + TFToStr(Period()) + ": trendline H :" + AlertTextCrossUp + ". \rPrice = " + DoubleToStr(Ask, 5) + ", H = " + DoubleToStr(H, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }                                                                                                                                          
    // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line) 
    if (Close[AlertCandle] < High1Buffer[AlertCandle]  && Close[AlertCandle+1] >= High1Buffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": trendline H :" + AlertTextCrossDown + ". \rPrice = " + DoubleToStr(Ask, 5) + ", H = " + DoubleToStr(H, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }
    // Lower bands
    // === Alert processing for crossover UP (indicator line crosses ABOVE signal line)
    if (Close[AlertCandle] > Low1Buffer[AlertCandle]  &&  Close[AlertCandle+1] <= Low1Buffer[AlertCandle+1])  { 
      AlertText = Symbol() + "," + TFToStr(Period()) + ": trendline L :" + AlertTextCrossUp + ". \rPrice = " + DoubleToStr(Bid, 5) + ", L = " + DoubleToStr(L, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];
    }                                                                                                                                          
    // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line) 
    if (Close[AlertCandle] < Low1Buffer[AlertCandle]  && Close[AlertCandle+1] >= Low1Buffer[AlertCandle+1])  {
      AlertText = Symbol() + "," + TFToStr(Period()) + ": trendline L :" + AlertTextCrossDown + ". \rPrice = " + DoubleToStr(Bid, 5) + ", L = " + DoubleToStr(L, 5) ;
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if(SendNotifications) SendNotification(AlertText);
      LastAlertTime = Time[0];                                                                                
    }                                                                                                
  }                                                                                                           
  return(0);                                                                                                  
}                          
