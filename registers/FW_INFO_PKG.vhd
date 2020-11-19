--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package FW_INFO_CTRL is
  type FW_INFO_FW_INFO_BUILD_DATE_MON_t is record
    DAY                        :std_logic_vector( 7 downto 0);
    MONTH                      :std_logic_vector( 7 downto 0);
    YEAR                       :std_logic_vector(15 downto 0);
  end record FW_INFO_FW_INFO_BUILD_DATE_MON_t;


  type FW_INFO_FW_INFO_BUILD_TIME_MON_t is record
    SEC                        :std_logic_vector( 7 downto 0);
    MIN                        :std_logic_vector( 7 downto 0);
    HOUR                       :std_logic_vector( 7 downto 0);
  end record FW_INFO_FW_INFO_BUILD_TIME_MON_t;


  type FW_INFO_FW_INFO_MON_t is record
    GIT_VALID                  :std_logic;   
    GIT_HASH_1                 :std_logic_vector(31 downto 0);
    GIT_HASH_2                 :std_logic_vector(31 downto 0);
    GIT_HASH_3                 :std_logic_vector(31 downto 0);
    GIT_HASH_4                 :std_logic_vector(31 downto 0);
    GIT_HASH_5                 :std_logic_vector(31 downto 0);
    BUILD_DATE                 :FW_INFO_FW_INFO_BUILD_DATE_MON_t;
    BUILD_TIME                 :FW_INFO_FW_INFO_BUILD_TIME_MON_t;
  end record FW_INFO_FW_INFO_MON_t;


  type FW_INFO_HOG_INFO_MON_t is record
    GLOBAL_FWDATE              :std_logic_vector(31 downto 0);
    GLOBAL_FWTIME              :std_logic_vector(31 downto 0);
    OFFICIAL                   :std_logic_vector(31 downto 0);
    GLOBAL_FWHASH              :std_logic_vector(31 downto 0);
    TOP_FWHASH                 :std_logic_vector(31 downto 0);
    XML_HASH                   :std_logic_vector(31 downto 0);
    GLOBAL_FWVERSION           :std_logic_vector(31 downto 0);
    TOP_FWVERSION              :std_logic_vector(31 downto 0);
    XML_VERSION                :std_logic_vector(31 downto 0);
    HOG_FWHASH                 :std_logic_vector(31 downto 0);
    FRAMEWORK_FWVERSION        :std_logic_vector(31 downto 0);
    FRAMEWORK_FWHASH           :std_logic_vector(31 downto 0);
  end record FW_INFO_HOG_INFO_MON_t;


  type FW_INFO_CONFIG_MON_t is record
    MAIN_CFG_COMPILE_HW        :std_logic;   
    MAIN_CFG_COMPILE_UL        :std_logic;   
    SECTOR_SIDE                :std_logic;   
    ST_nBARREL_ENDCAP          :std_logic;   
    ENDCAP_nSMALL_LARGE        :std_logic;   
    ENABLE_NEIGHBORS           :std_logic;   
    SECTOR_ID                  :std_logic_vector(31 downto 0);
    PHY_BARREL_R0              :std_logic_vector(31 downto 0);
    PHY_BARREL_R1              :std_logic_vector(31 downto 0);
    PHY_BARREL_R2              :std_logic_vector(31 downto 0);
    PHY_BARREL_R3              :std_logic_vector(31 downto 0);
    HPS_ENABLE_ST_INN          :std_logic;                    
    HPS_ENABLE_ST_EXT          :std_logic;                    
    HPS_ENABLE_ST_MID          :std_logic;                    
    HPS_ENABLE_ST_OUT          :std_logic;                    
    HPS_NUM_MDT_CH_INN         :std_logic_vector( 7 downto 0);
    HPS_NUM_MDT_CH_EXT         :std_logic_vector( 7 downto 0);
    HPS_NUM_MDT_CH_MID         :std_logic_vector( 7 downto 0);
    HPS_NUM_MDT_CH_OUT         :std_logic_vector( 7 downto 0);
    NUM_MTC                    :std_logic_vector( 7 downto 0);
    NUM_NSP                    :std_logic_vector( 7 downto 0);
    UCM_ENABLED                :std_logic;                    
    MPL_ENABLED                :std_logic;                    
    SF_ENABLED                 :std_logic;                    
    SF_TYPE                    :std_logic;                    
    NUM_DAQ_STREAMS            :std_logic_vector( 7 downto 0);
    MAX_NUM_HP                 :std_logic_vector( 7 downto 0);
    MAX_NUM_HPS                :std_logic_vector( 7 downto 0);
    NUM_SF_INPUTS              :std_logic_vector( 7 downto 0);
    NUM_SF_OUTPUTS             :std_logic_vector( 7 downto 0);
    MAX_NUM_SL                 :std_logic_vector( 7 downto 0);
    NUM_THREADS                :std_logic_vector( 7 downto 0);
  end record FW_INFO_CONFIG_MON_t;


  type FW_INFO_MON_t is record
    FW_INFO                    :FW_INFO_FW_INFO_MON_t;
    HOG_INFO                   :FW_INFO_HOG_INFO_MON_t;
    CONFIG                     :FW_INFO_CONFIG_MON_t;  
  end record FW_INFO_MON_t;




end package FW_INFO_CTRL;