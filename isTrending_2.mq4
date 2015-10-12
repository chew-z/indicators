//+------------------------------------------------------------------+
//|                                                 isTrending_2.mq4 |
//| rysuje linie dziennego Hi/Lo dla ka¿dej timeframe                |
//| badany zakres jest funkcj¹ pochodnej zmiennoœci                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013,2015 chew-z"
#property link      "isTrending"
#include <TradeTools\TradeTools5.mqh>
#include <TradeContext.mq4>
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green    // Color of the Long line
#property indicator_color2 Red      // Color of the Short line
//---- indicator parameters

//---- buffers
double ShortBuffer[];
double LongBuffer[];
//--- parameters
int Short, Long;

int OnInit()    {

    SetIndexBuffer(0,LongBuffer);
    SetIndexBuffer(1,ShortBuffer);
    SetIndexStyle (1,DRAW_LINE,STYLE_SOLID, 2);
    SetIndexStyle (0,DRAW_LINE,STYLE_SOLID, 2);
    SetIndexDrawBegin(1,0);
    SetIndexDrawBegin(0,0);
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

   Print(__FUNCTION__,"_Deinitalization reason code = ", getDeinitReasonText(reason));
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])       {
// repaint only on new bar, chart refresh etc.
// http://forum.mql4.com/64114
if (prev_calculated != rates_total) {
        int i,                              // indeksy
           Counted_bars;                    // Number of counted bars

        Counted_bars = IndicatorCounted();  // Number of counted bars
        i = Bars-Counted_bars-1;            // Index of the first uncounted
        while(i>=0)    {                    // Loop for uncounted bars
        // Teraz sprawdzamy isTrending
            Short = isTrending_S(i);
            Long = isTrending_L(i);
            ShortBuffer[i] = Short;
            LongBuffer[i] = Long;
          i--;
        } // while
   } //prev_calc
   return(rates_total); // exit
}

/////////////////////////// SIGNALS ////////////////////////////////////
bool isTrending_L(int j) { // Czy œrednia szybka powy¿ej wolnej?
int i;
double M;
int sig = 0;
   for (i = K; i>-1; i--) {
      M = iMA(NULL,PERIOD_D1,maxPeriod,i,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+0);
      if (iMA(NULL,PERIOD_D1,minPeriod,i,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+0) > M)
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
   for (i = K; i>-1; i--) {
      M = iMA(NULL,PERIOD_D1,maxPeriod,i,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+0);
      if (iMA(NULL,PERIOD_D1,minPeriod,i,MODE_EMA,PRICE_CLOSE,iBarShift(NULL,PERIOD_D1,Time[j],false)+0) < M)
         sig++;
   }
   if(sig < K)
      return(false);
   else
      return(true);
}