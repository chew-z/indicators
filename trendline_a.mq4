//+------------------------------------------------------------------+
//|                                                   tendline_a.mq4      |
//| rysuje linie trendu                                                    |
//| dodatkowo wysyła alerty                                         |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, chew-z"
#property link      "trendline_a"
#include <TradeTools.mqh>
#include <TradeContext.mq4>
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red      // Color of the High line 2
#property indicator_color2 Green   // Color of the High line 1

//---- indicator parameters
extern int rangeX = 50;

//---- buffers
double Low1Buffer[];
double High1Buffer[];

//---- alerts
extern int     AlertCandle              = 0;      // 1 - last fully formed candle, 0 - current forming candle
datetime       LastAlertTime         = -999999;
string         AlertTextCrossUp       = " cross UP";
string         AlertTextCrossDown  = " cross DOWN";

int init()
  {
   SetIndexBuffer(1,Low1Buffer);
   SetIndexBuffer(0,High1Buffer);

   SetIndexStyle (1,DRAW_LINE,STYLE_DASHDOT, 1);
   SetIndexStyle (0,DRAW_LINE,STYLE_DASHDOTDOT, 1);

   SetIndexDrawBegin(1,0);
   SetIndexDrawBegin(0,0);
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
   int min2 = Find2Peak(min1);
   double deltaYh = (High[max1]-High[max2]) / (max1 - max2);    // delta Y High
   double deltaYl = (Low[min1]-Low[min2]) / (min1 - min2);          // delta Y Low

 while(i>=0)    {                                      // Loop for uncounted bars  
    if(i <= rangeX) {
      High1Buffer[i] = High[max1] - (max1 - i) * deltaYh;
      Low1Buffer[i] = Low[min1] + (min1 - i) * deltaYh;
    }
    i--; 
  } // while

    
   return(0); // exit
}

int FindPeak() { // starts looking rangeX (extern variable) bars from 0

double maxY = High[rangeX];
int maxA = rangeX;

  for (int k = rangeX; k > 0 ; k--) {
    if(High[k] > maxY) {
      maxA = k;
      maxY = High[maxA];
    }
   }
 return (maxA);
}

int Find2Peak(int maxB) { // starts looking half-way (FindPeak()/2) from previous peak [only lower peaks]

double maxY = High[1];
int maxA = 1;

  for (int k = MathRound(maxB/2); k > 0 ; k--) {
    if(High[k] > maxY) {
      maxA = k;
      maxY = High[maxA];
    }
   }
 return (maxA);
}

int FindValley() { // starts looking rangeX (extern variable) bars from 0

double minY = Low[rangeX];
int minA = rangeX;

  for (int k = rangeX; k > 0 ; k--) {
    if(Low[k] < minY) {
      minA = k;
      minY = Low[minA];
    }
   }
 return (minA);
}

int Find2Valley(int minB) { // starts looking half-way (FindPeak()/2) from previous peak [only lower peaks]

double minY = Low[1];
int minA = 1;

  for (int k = MathRound(minB/2); k > 0 ; k--) {
    if(Low[k] < minY) {
      minA = k;
      minY = Low[minA];
    }
   }
 return (minA);
}