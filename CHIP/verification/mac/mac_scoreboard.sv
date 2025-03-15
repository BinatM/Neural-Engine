class mac_scoreboard;
    function void check_result(logic [21:0] expected, logic [21:0] actual);
        if (expected !== actual)
            $error("MAC Mismatch! Expected: %0d, Got: %0d", expected, actual);
        else
            $display("MAC PASS: Expected = Actual = %0d", actual);
    endfunction
endclass
