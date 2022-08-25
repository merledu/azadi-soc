
package prog_image_loader_pkg;

  function automatic void read_hex(string hex_file, ref bit [7:0] prog_image [int]);
    int       hex_fd;
    string    astring, addr_string;
    int       addr;
    bit [7:0] data;
  
    hex_fd = $fopen(hex_file, "r");
  
    if (hex_fd == 0)
      $display("Hex file not opened! Check path.");
    else 
      $display("Hex file opened succesfully!!!");
  
    addr = '0;
    while ($fscanf(hex_fd, "%s", astring) != 0 && !$feof(hex_fd)) begin
      if (astring[0] == "@" && astring.len() > 1) begin
        addr_string = astring.substr(1, astring.len()-1);
        addr = addr_string.atohex();
      end
      else begin
        data = astring.atohex();
        prog_image[addr] = data;
        addr++;
      end
    end
    $fclose(hex_fd);
  endfunction: read_hex

endpackage: prog_image_loader_pkg