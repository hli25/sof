#
# Topology for generic Apollolake UP^2 with es8316 codec.
#

# Include topology builder
include(`utils.m4')
include(`dai.m4')
include(`pipeline.m4')
include(`ssp.m4')

# Include TLV library
include(`common/tlv.m4')

# Include Token library
include(`sof/tokens.m4')

# Include Apollolake DSP configuration
include(`platform/intel/cnl.m4')
include(`platform/intel/dmic.m4')
DEBUG_START
#
# Define the pipelines
#
# PCM0 <----> volume <-----> SSP2 (es8316)
#

dnl PIPELINE_PCM_ADD(pipeline,
dnl     pipe id, pcm, max channels, format,
dnl     period, priority, core,
dnl     pcm_min_rate, pcm_max_rate, pipeline_rate,
dnl     time_domain, sched_comp)

# Low Latency playback pipeline 1 on PCM 0 using max 2 channels of s32le.
# 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(sof/pipe-volume-playback.m4,
	1, 0, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000)

# Low Latency capture pipeline 2 on PCM 0 using max 2 channels of s32le.
# 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(sof/pipe-low-latency-capture.m4,
	2, 0, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000)
# Low Latency capture pipeline 3 on PCM 1 using max 4 channels of s32le.
# 1000us deadline on core 0 with priority 0
#PIPELINE_PCM_ADD(sof/pipe-passthrough-capture.m4,
#	3, 2, 4, s32le,
#	1000, 0, 0,
#	48000, 48000, 48000)

#
# DAIs configuration
#

dnl DAI_ADD(pipeline,
dnl     pipe id, dai type, dai_index, dai_be,
dnl     buffer, periods, format,
dnl     deadline, priority, core, time_domain)

# playback DAI is SSP2 using 2 periods
# Buffers use s24le format, 1000us deadline on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	1, SSP, 2, SSP2-Codec,
	PIPELINE_SOURCE_1, 2, s24le,
	1000, 0, 0, SCHEDULE_TIME_DOMAIN_DMA)

# capture DAI is SSP2 using 2 periods
# Buffers use s24le format, 1000us deadline on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	2, SSP,2, SSP2-Codec,
	PIPELINE_SINK_2, 2, s24le,
	1000, 0, 0, SCHEDULE_TIME_DOMAIN_DMA)

# capture DAI is DMIC0 using 2 periods
# Buffers use s32le format, 1000us deadline on core 0 with priority 0
#DAI_ADD(sof/pipe-dai-capture.m4,
#	3, DMIC, 0, dmic01,
#	PIPELINE_SINK_3, 2, s32le,
#	1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER)
# PCM Low Latency, id 0
PCM_DUPLEX_ADD(ES8336, 0, PIPELINE_PCM_1, PIPELINE_PCM_2)
#PCM_CAPTURE_ADD(DMIC, 1, PIPELINE_PCM_3)
#
# BE configurations - overrides config in ACPI if present
#

DAI_CONFIG(SSP, 2, 0, SSP2-Codec,
	SSP_CONFIG(I2S, SSP_CLOCK(mclk, 19200000, codec_mclk_in),
		SSP_CLOCK(bclk, 4800000, codec_slave),
		SSP_CLOCK(fsync, 48000, codec_slave),
		SSP_TDM(2, 32, 3, 3),
		SSP_CONFIG_DATA(SSP, 2, 24, 1)))
# dmic01 (id: 1)

#DAI_CONFIG(DMIC, 0, 1, dmic01,
#	   DMIC_CONFIG(1, 2400000, 4800000, 40, 60, 48000,
#		DMIC_WORD_LENGTH(s32le), 400, DMIC, 0,
#		PDM_CONFIG(DMIC, 0, STEREO_PDM0)))

VIRTUAL_WIDGET(ssp0 Rx, out_drv, 1)
VIRTUAL_WIDGET(ssp0 Tx, out_drv, 2)
VIRTUAL_WIDGET(DMIC01 Rx, out_drv, 3)
VIRTUAL_WIDGET(DMic, out_drv, 4)
VIRTUAL_WIDGET(dmic01_hifi, out_drv, 5)

VIRTUAL_WIDGET(codec0_out, output, 6)
VIRTUAL_WIDGET(codec0_in, input, 7)
DEBUG_END


