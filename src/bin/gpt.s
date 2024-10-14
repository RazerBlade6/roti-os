;This is GUID Partition Table, Not Generatively Pre-trained Transformer
struc GPT_HEADER
        .Signature:                     UINT64                      
        .Revision:                      UINT32
        .HeaderSize:                    UINT32
        .HeaderCRC32:                   UINT32
        .Reserved:                      UINT32
        .MyLBA:                         UINT64
        .AlternateLBA:                  UINT64
        .LastUsableLBA:                 UINT64
        .DiskGUID:                      UINT64
                                        UINT64
        .PartitionEntryLBA:             UINT64
        .NumberOfPartitionEntries:      UINT32
        .SizeOfPartitionEntry:          UINT32
        .PartitionEntryArrayCRC32:      UINT32
        .Reserved2:                     UINT32   
endstruc