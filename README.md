# AES_Hardware_Accelarator
                ┌──────────────┐
 AXI WRITE ---> │  axi_regs    │
                │              │
                │ DATA_IN[ ]   │
                │ IV_W[ ]      │
                │ MODE         │
                │ CTRL         │
                └─────┬────────┘
                      │
                ┌─────▼────────┐
                │ axi_control  │
                │              │
                │ plaintext_lat│
                │ iv_lat       │
                │ mode_lat     │
                │ aes_start ──────────────┐
                └─────┬────────┘           │
                      │                    │
              ┌───────▼────────┐           │
              │ aes_mode_ctrl  │           │
              │                │           │
              │ fb_load_iv     │           │
              │ fb_update      │           │
              │ ctr_load       │           │
              │ ctr_inc        │           │
              └───┬─────────┬─┘           │
                  │         │             │
        ┌─────────▼───┐ ┌──▼──────────┐  │
        │ feedback_reg │ │ ctr_reg_128 │  │
        │              │ │              │  │
        │ feedback     │ │ ctr          │  │
        └──────┬───────┘ └──────┬───────┘  │
               │                │          │
               └───────┬────────┘          │
                       ▼                   │
                 ┌──────────────┐          │
                 │ aes_input_mux│          │
                 │              │          │
                 │ aes_in       │──────────┘
                 └──────┬───────┘
                        ▼
                 ┌──────────────┐
                 │ AES_Encrypt  │
                 │ (ECB core)   │
                 │              │
                 │ aes_out      │
                 │ done         │
                 └──────────────┘
