extern "C" {
#include <rte_eal.h>
#include <rte_ethdev.h>
#include <rte_mbuf.h>
}
#include <cstdio>
#include <cstdlib>

static const uint16_t RX_RING_SIZE = 1024;
static const uint16_t TX_RING_SIZE = 1024;
static const uint16_t BURST_SIZE   = 256;
static const uint16_t PORT_ID      = 0;

int main(int argc, char** argv) {
    if (rte_eal_init(argc, argv) < 0) { 
        std::fprintf(stderr, "EAL init failed\n"); 
        return 1;
     }
    if (!rte_eth_dev_is_valid_port(PORT_ID)) { 
        std::fprintf(stderr, "Port 0 not found\n");
         return 1;
     }

    uint16_t nb_rxq = 1, nb_txq = 1;
    rte_eth_conf port_conf{};
    port_conf.rxmode.mq_mode = RTE_ETH_MQ_RX_NONE;

    if (rte_eth_dev_configure(PORT_ID, nb_rxq, nb_txq, &port_conf) < 0) { 
        std::fprintf(stderr, "configure failed\n");
         return 1;
     }

    const unsigned socket_id = rte_socket_id();
    rte_mempool* mbuf_pool = rte_pktmbuf_pool_create("MBUF_POOL", 8192, 256, 0, RTE_MBUF_DEFAULT_BUF_SIZE, socket_id);
    if (!mbuf_pool) { 
        std::fprintf(stderr, "mempool create failed\n"); 
        return 1;
     }

    if (rte_eth_rx_queue_setup(PORT_ID, 0, RX_RING_SIZE, socket_id, nullptr, mbuf_pool) < 0) { 
        std::fprintf(stderr, "rx setup failed\n");
         return 1; 
    }
    if (rte_eth_tx_queue_setup(PORT_ID, 0, TX_RING_SIZE, socket_id, nullptr) < 0) { 
        std::fprintf(stderr, "tx setup failed\n");
         return 1;
     }

    if (rte_eth_dev_start(PORT_ID) < 0) {
         std::fprintf(stderr, "dev start failed\n"); 
         return 1;
     }
    rte_eth_promiscuous_enable(PORT_ID);

    std::printf("DPDK RX loop on port %u…\n", PORT_ID);

    rte_mbuf* bufs[BURST_SIZE];
    uint64_t total = 0;

    while (true) {
        const uint16_t nb = rte_eth_rx_burst(PORT_ID, 0, bufs, BURST_SIZE);
        if (nb == 0) continue;
        total += nb;

        // Do something per packet here (parse headers, etc.)
        // For now, just free (drop) them.
        for (uint16_t i = 0; i < nb; i++) rte_pktmbuf_free(bufs[i]);

        if ((total & ((1ull<<20)-1)) == 0) { // print occasionally
            std::printf("rx=%llu\n", (unsigned long long)total);
        }
    }
}
