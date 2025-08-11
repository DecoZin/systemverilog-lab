// Name: André Lamego
// Date: 08/11/2025
// Description: Testbench module for Class Counter

module counterclass;

// add counter class here 
    protected int count;

    function  new(input int count = 0);
        this->count = count;

    endfunction

    function void load(input int count);
        this->count = count;
        
    endfunction

    function int getcount();
        return this->count;
        
    endfunction

endmodule
