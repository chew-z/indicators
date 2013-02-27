//+------------------------------------------------------------------+
//|                                                   lookBack_4.mq4 |
//| rysuje linie dziennego Hi/Lo dla ka¿dej timeframe                |
//| badany zakres jest funkcj¹ pochodnej zmiennoœci                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, chew-z"
#property link      "isTrending - based on daily MA crossover"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green    // Color of the Long line
#property indicator_color2 Red      // Color of the Short line
#property indicator_color3 Gold     // Color of the MA line
//---- indicator parameters
extern int K = 5;
extern int minPeriod = 5;
extern int maxPeriod = 20;
//---- buffers
double ShortBuffer[];
double LongBuffer[];
double MABuffer[];
//--- parameters

int iDay;
int S, L;

int init()
  {
   SetIndexBuffer(2,MABuffer);
   SetIndexBuffer(0,LongBuffer); 
   SetIndexBuffer(1,ShortBuffer);
   SetIndexStyle (2,DRAW_LINE,STYLE_SOLID, 1);
   SetIndexStyle (1,DRAW_LINE,STYLE_SOLID, 2);
   SetIndexStyle (0,DRAW_LINE,STYLE_SOLID, 2);
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
   
   iDay = iBarShift(NULL, PERIOD_D1, Time[i],false) + 1; //Zamienia indeks bie¿¹cego baru na indeks dziennego Open (!! z poprzedniego dnia !!)
   

// Teraz sprawdzamy isTrending
   S = isTrending_S(i);
   L = isTrending_L(i);
   ShortBuffer[i] = S;
   LongBuffer[i] = L;
   MABuffer[i] = 0.0;
   i--; 
} // while
   return(0); // exit
}

int deinit()     {
   Comment("Dynamic Breakout Levels (k-days Hi, Lo) - as a derivative of daily StdDev change");
}
/////////////////////////// SIGNALS ////////////////////////////////////
bool isTrending_L(int j) { // Czy œrednia szybka powy¿ej wolnej?
int i;
double M;
int sig = 0;
   for (i = K; i>0; i--) {
      M = iMA(NULL,PERIOD_D1,maxPeriod,i-1,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+0);
      if (iMA(NULL,PERIOD_D1,minPeriod,i-1,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+0) > M)
         sig++;
   }
   if(sig < K)
      return(false);
   else 
      return(true);
}
bool isTrending_S(int j) { // Czy œrednia szybka poni¿ej wolnej?
int i;
double M;
int sig = 0;
   for (i = K; i>0; i--) {
      M = iMA(NULL,PERIOD_D1,maxPeriod,i-1,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+0);
      if (iMA(NULL,PERIOD_D1,minPeriod,i-1,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+0) < M)
         sig++;
   }
   if(sig < K)
      return(false);
   else 
      return(true);
}

//double MA_1_Day_Ago = iMA(NULL,PERIOD_D1,maxPeriod,0,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+1);
//double MA_2_Day_Ago = iMA(NULL,PERIOD_D1,minPeriod,0,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+1);