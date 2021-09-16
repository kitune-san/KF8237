//
// KF8237
// PROGRAMMABLE DMA CONTROLLER
//
// Written by Kitune-san
//

module KF8237 (
    input   logic           clock,
    input   logic           reset,
    input   logic           chip_select_n,
    input   logic           ready,
    input   logic           hold_acknowledge,
    input   logic   [3:0]   dma_request,
    input   logic   [7:0]   data_bus_in,
    output  logic   [7:0]   data_bus_out,
    input   logic           io_read_n_in,
    output  logic           io_read_n_out,
    input   logic           io_write_n_in,
    output  logic           io_write_n_out,
    input   logic           end_of_process_in,
    output  logic           end_of_process_out,
    input   logic   [3:0]   address_in,
    input   logic   [15:0]  address_out,
    output  logic           hold_request,
    output  logic   [3:0]   dma_acknowledge,
    output  logic           address_enable,
    output  logic           address_strobe,
    output  logic           memory_read_n,
    output  logic           memory_write_n
);

    //
    // Data Bus Buffer & Read/Write Control Logic (1)
    //
    logic           lock_bus_control;
    logic   [7:0]   internal_data_bus;
    logic           write_command_register;
    logic           write_mode_register;
    logic           write_request_register;
    logic           set_or_reset_mask_register;
    logic           write_mask_register;
    logic   [3:0]   write_base_and_current_address;
    logic   [3:0]   write_base_and_current_word_count;
    logic           clear_byte_pointer;
    logic           master_clear;
    logic           clear_mask_register;
    logic           read_temporary_register;
    logic           read_status_register;
    logic   [3:0]   read_current_address;
    logic   [3:0]   read_current_word_count;

    KF8237_Bus_Control_Logic u_Bus_Control_Logic (
        // Bus
        .clock                              (clock),
        .reset                              (reset),

        .chip_select_n                      (chip_select_n),
        .io_read_n_in                       (io_read_n_in),
        .io_write_n_in                      (io_write_n_in),
        .address_in                         (address_in),
        .data_bus_in                        (data_bus_in),

        .lock_bus_control                   (lock_bus_control),

        // Internal Bus
        .internal_data_bus                  (internal_data_bus),
        // -- write
        .write_command_register             (write_command_register),
        .write_mode_register                (write_mode_register),
        .write_request_register             (write_request_register),
        .set_or_reset_mask_register         (set_or_reset_mask_register),
        .write_mask_register                (write_mask_register),
        .write_base_and_current_address     (write_base_and_current_address),
        .write_base_and_current_word_count  (write_base_and_current_word_count),
        // -- software command
        .clear_byte_pointer                 (clear_byte_pointer),
        .master_clear                       (master_clear),
        .clear_mask_register                (clear_mask_register),
        // -- read
        .read_temporary_register            (read_temporary_register),
        .read_status_register               (read_status_register),
        .read_current_address               (read_current_address),
        .read_current_word_count            (read_current_word_count)
    );


    //
    // Priority Encoder And Rotating Priority Logic
    //
    logic   [1:0]   dma_rotate;
    logic   [3:0]   edge_request;
    logic   [3:0]   encoded_dma;
    logic           end_of_process;
    logic   [3:0]   dma_acknowledge_internal;

    KF8237_Priority_Encoder u_Priority_Encoder (
        .clock                              (clock),
        .reset                              (reset),

        // Internal Bus
        .internal_data_bus                  (internal_data_bus),
        // -- write
        .write_command_register             (write_command_register),
        .write_request_register             (write_request_register),
        .set_or_reset_mask_register         (set_or_reset_mask_register),
        .write_mask_register                (write_mask_register),
        // -- software command
        .master_clear                       (master_clear),
        .clear_mask_register                (clear_mask_register),

        // Internal signals
        .dma_rotate                         (dma_rotate),
        .edge_request                       (edge_request),
        .encoded_dma                        (encoded_dma),
        .end_of_process                     (end_of_process),
        .dma_acknowledge_internal           (dma_acknowledge_internal),

        // External signals
        .dma_request                        (dma_request)
    );


    //
    // Address And Count Registers
    //
    logic   [7:0]   read_address_or_count;
    logic   [3:0]   transfer_register_select;
    logic           initialize_current_register;
    logic           decrement_address_config;
    logic           next_word;
    logic           underflow;
    logic   [15:0]  transfer_address;

    KF8237_Address_And_Count_Registers u_Address_And_Count_Registers (
        .clock                              (clock),
        .reset                              (reset),

        // Internal Bus
        .internal_data_bus                  (internal_data_bus),
        .read_address_or_count              (read_address_or_count),
        // -- write
        .write_base_and_current_address     (write_base_and_current_address),
        .write_base_and_current_word_count  (write_base_and_current_word_count),
        // -- software command
        .clear_byte_pointer                 (clear_byte_pointer),
        .master_clear                       (master_clear),
        // -- read
        .read_current_address               (read_current_address),
        .read_current_word_count            (read_current_word_count),

        // Internal signals
        .transfer_register_select           (transfer_register_select),
        .initialize_current_register        (initialize_current_register),
        .decrement_address_config           (decrement_address_config),
        .next_word                          (next_word),
        .underflow                          (underflow),
        .transfer_address                   (transfer_address)
    );

endmodule

