//+------------------------------------------------------------------+
//|                                                   trendline_2a.mq4   |
//| rysuje linie trendu                                                    |
//|                                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, chew-z"
#property link      "trendline_2a"
#include <TradeTools.mqh>
#include <TradeContext.mq4>
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Orange      // Color of the High trendline 
#property indicator_color2 Yellow   // Color of the Low trendline 
#property indicator_color3 Blue 
//---- indicator parameters
//---- buffers
double Low1Buffer[];
double High1Buffer[];
double N1Buffer[];
//---- alerts
extern int     AlertCandle              = 0;      // 1 - last fully formed candle, 0 - current forming candle
datetime       LastAlertTime         = -999999;
string         AlertTextCrossUp       = " trendline cross UP";
string         AlertTextCrossDown  = " trendline cross DOWN";

int init()    {
   AlertEmailSubject = Symbol() + " trendline alert"; 
   GlobalVariableSet(StringConcatenate(Symbol(), "_trendline_2"), 0);

   SetIndexBuffer(2,N1Buffer);
   SetIndexBuffer(1,Low1Buffer);
   SetIndexBuffer(0,High1Buffer);

   SetIndexStyle (2,DRAW_LINE,STYLE_DASH, 1);
   SetIndexStyle (1,DRAW_LINE,STYLE_DASH, 1);
   SetIndexStyle (0,DRAW_LINE,STYLE_DASH, 1);

   SetIndexDrawBegin(2,0);
   SetIndexDrawBegin(1,0);
   SetIndexDrawBegin(0,0);
   return(0);
  }
int deinit()    {
   GlobalVariableDel(StringConcatenate(Symbol(), "_trendline_2"));
   return(0);
   }
int start()    { 
     int i, half, Counted_bars;          // Number of counted bars     
     Counted_bars = IndicatorCounted();  // Number of counted bars
     i = Bars-Counted_bars-1;            // Index of the first uncounted
     int max1 = iHighest(NULL, 0, MODE_HIGH, rangeX, 1); //roughly 24 H1 bars per day
         half = MathRound(max1/2) + 1;                // starts looking half-way from previous peak [not only lower peaks]
     int max2 = iHighest(NULL, 0, MODE_HIGH, half, 1);
     int min1 = iLowest(NULL, 0, MODE_LOW, rangeX, 1);
         half = MathRound(min1/2) + 1;
     int min2 = iLowest(NULL, 0, MODE_LOW, half, 1);
     double deltaYh = (High[max1]-High[max2]) / (max1 - max2);    // delta Y High
     double deltaYl = (Low[min2]-Low[min1]) / (min1 - min2);          // delta Y Low
     // Print the dates of peaks and valleys on chart
     Comment("Max1 "+DoubleToStr(High[max1],4)+" "+TimeToStr(Time[max1], TIME_DATE)+" Max2 "+DoubleToStr(High[max2],4)+" "+TimeToStr(Time[max2], TIME_DATE)+
             " Min1 "+DoubleToStr(Low[min1],4)+" "+TimeToStr(Time[min1], TIME_DATE)+" Min2 "+DoubleToStr(Low[min2],4)+" "+TimeToStr(Time[min2], TIME_DATE));
     while(i>=0)    {                                      // Loop for uncounted bars  
        if(i <= rangeX) {
          High1Buffer[i]  = High[max1] - (max1 - i) * deltaYh;
          Low1Buffer[i]   = Low[min1] + (min1 - i) * deltaYl;
          N1Buffer[i] = (High1Buffer[i] + Low1Buffer[i])/2;
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

