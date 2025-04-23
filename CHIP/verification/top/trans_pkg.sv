package trans_pkg;
	// A single transaction can be a pixel-weight pair or a threshold load
	typedef struct packed {
	  logic [7:0]  pixel;
	  logic [7:0]  weight;
	  logic        is_threshold;       // 0 = pixel/weight, 1 = threshold
	  logic [21:0] threshold;          // valid when is_threshold==1
	} trans_t;

	// Mailboxes for driver?monitor?scoreboard communication
	mailbox #(trans_t) drv_mbx = new();
	mailbox #(trans_t) mon_mbx = new();
  endpackage : trans_pkg
