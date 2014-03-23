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
extern int rangeX = 50;

//---- buffers
double Low1Buffer[];
double High1Buffer[];

//---- alerts
extern int     AlertCandle              = 0;      // 1 - last fully formed candle, 0 - current forming candle
extern int     MaxCounter       = 100;
datetime       LastAlertTime         = -999999;
string         AlertTextCrossUp       = " cross UP";
string         AlertTextCrossDown  = " cross DOWN";
int counter                             = 0;

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
  counter = GlobalVariableGet(StringConcatenate(Symbol(), "_trendline"));
  if ( counter < 1 ) {
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
    counter = MaxCounter;
    GlobalVariableSet(StringConcatenate(Symbol(), "_trendline"), counter);
  } else { // iddle for N ticks
      counter--;
      GlobalVariableSet(StringConcatenate(Symbol(), "_trendline"), counter);
  }
    
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

int FindPeak() { // starts looking rangeX (extern variable) bars from 0

double maxY = High[rangeX];
int maxA = rangeX;

  for (int k = rangeX; k > 0 ; k--) {
    if(High[k] > maxY) {
      maxA = k;
      maxY = High[k];
    }
   }
// Print("FindPeak "+maxA);
 return (maxA);
}

int Find2Peak(int maxB) { 

int K = (int) MathRound(maxB/2) + 1; // starts looking half-way (FindPeak()/2) from previous peak [only lower peaks]
double maxY = High[1];
int maxA = 1;

  for (int k = 1; k < K; k++) {
// Print("maxY "+maxY+" High[k] "+High[k]);
    if(High[k] > maxY) {
      maxA = k;
      maxY = High[k];
    }
   }
// Print("Find2Peak "+maxA);
 return (maxA);
}

int FindValley() { // starts looking rangeX (extern variable) bars from 0

double minY = Low[rangeX];
int minA = rangeX;

  for (int k = rangeX; k > 0 ; k--) {
// Print("minY "+minY+" Low[k]" +Low[k]);
    if(Low[k] < minY) {
      minA = k;
      minY = Low[k];
    }
   }
// Print("FindValley " + minA);
 return (minA);
}

int Find2Valley(int minB) { 

int K = (int) MathRound(minB/2) + 1;  // starts looking half-way (FindPeak()/2) from previous peak [only lower peaks]
double minY = Low[1];
int minA = 1;

  for (int k = 1; k < K; k++) {
//Print("minY "+minY+" Low[k]" +Low[k]);
    if(Low[k] < minY) {
      minA = k;
      minY = Low[k];
    }
   }
 //Print("Find2Valley " + minA);
 return (minA);
}