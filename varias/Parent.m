function Parent()
   GIFT=HandleObject('Trampoline')
   giveDaughter(GIFT);
   GIFT.Object
end
 
function giveDaughter(receivedGIFT)
receivedGIFT.Object=['broken ',receivedGIFT.Object];
end
