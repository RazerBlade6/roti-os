bits 64

%include "./src/bin/efi_defs.s"
%include "./src/bin/efi_boot_services.s"
%include "./src/bin/efi_text_output_services.s"
%include "./src/bin/mbr.s"
%include "./src/bin/gpt.s"

section .text
global  start

start:
    mov [ptrUEFI], rsp
    mov [imageHandle], rcx
    mov [systemTable], rdx
    sub rsp, 4 * 8
    
    ; In theory, this should be all we have to do
    ; Should probably include a verification step
    ; So we don't accidentally blow up the emulator

    call getFrameBuffer
    call exitBootSequence
    call loadKernel

setupProtectiveMbr:
    mov rax, [ptrLBA0]
    mov rax, [rax + MASTER_BOOT_RECORD.BootStrapCode]
    mov [rax], ptrLBA0

    call [rax]

getFrameBuffer:
    call locateProtocol
    
    mov  rcx, [ptrInterface]
    mov  rcx, [rcx + EFI_GRAPHICS_OUTPUT_PROTOCOL.Mode]
    mov  rcx, [rcx + EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE.FrameBufferBase]
 
    mov  [frameBuffer], rcx
    
    ret

exitBootSequence:
    call getMemoryMap
    call exitBootServices
    ret

loadKernel:
    call clearScreen
    lea  rdx, string
    call outputString
    lea  rdx, exitString
    call outputString
    
    call exitKernel

exitKernel:
    hlt
    jmp exitKernel

EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID:  dd   0x9042a9de
                                    dd   0x23dc4a38
                                    dd   0x96fb7ade
                                    dd   0xd080516a

section .data
        string                      db   __utf16__ 'Hello World', 13, 10, 13, 10
        exitString                  db   __utf16__ 'Press any key to shutdown...'
        ptrUEFI                     dq   0
        imageHandle                 dq   0
        systemTable                 dq   0
        ptrInterface                dq   0
        memoryMapSize               dq   EFI_MEMORY_DESCRIPTOR_size * 1024
        memoryMap                   resb EFI_MEMORY_DESCRIPTOR_size * 1024 ; reserving 1 KiB of memory at this time
        mapKey                      dq   0
        descriptorSize              dq   0
        descriptorVersion           dd   0
        frameBuffer                 dq   0
        ptrLBA0                     dq   0

        bootStrapCode     times 440 db   0
        uniqueMbrSignature          dd   0
        unknown                     dw   0
        partition                   db   0          ; bootIndicator
                                    db   0          ; startHead
                                    db   0          ; startSector
                                    db   2          ; startTrack
                                    db   0xEE       ; OSType
                                    db   0xFF       ; endHead
                                    db   0xFF       ; endSector
                                    db   0xFF       ; endTrack
                                    dd   0xFFFFFFFF ; sizeInLBA
                            times 6 dq   0          ; Remaining (Empty) partitions
        signature                   dw   0xAA55

        lbaSize                     dq   512
        espSize                     dq   1024 * 1024 * 32 ; 32 MiB
        dataSize                    dq   1024 * 1024