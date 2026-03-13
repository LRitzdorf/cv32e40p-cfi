/*
* Copyright 2019 ETH Zürich and University of Bologna
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

.section .vectors, "ax"
.option norvc
vector_table:
	j sw_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j verification_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler
	j __no_irq_handler

/* this is fixed to 0x8000, used for PULP_SECURE=0. We redirect this entry to the
new vector table (which is at mtvec) */
/* .section .legacy_irq, "ax" */
/*	j vector_table */
/*	j __no_irq_handler */
/*	j __no_irq_handler */
/*	j __no_irq_handler */

.section .text.vecs
/* exception handling */
__no_irq_handler:
	la a0, no_exception_handler_msg
	jal ra, puts
	j __no_irq_handler


sw_irq_handler:
	/* save all registers, even temporaries! */
	addi sp, sp, -64
	sw ra, 60(sp)
	sw a0, 56(sp)
	sw a1, 52(sp)
	sw a2, 48(sp)
	sw a3, 44(sp)
	sw a4, 40(sp)
	sw a5, 36(sp)
	sw a6, 32(sp)
	sw a7, 28(sp)
	sw t0, 24(sp)
	sw t1, 20(sp)
	sw t2, 16(sp)
	sw t3, 12(sp)
	sw t4, 8(sp)
	sw t5, 4(sp)
	sw t6, 0(sp)
	/* identify specific exception and respond */
	csrr t0, mcause
	slli t0, t0, 1  /* shift off the high bit */
	srli t0, t0, 1
	li t1, 18
	beq t0, t1, handle_software_check
	li t1, 2
	beq t0, t1, handle_illegal_insn
	li t1, 11
	beq t0, t1, handle_ecall
	li t1, 3
	beq t0, t1, handle_ebreak
	j handle_unknown

handle_ecall:
	la a0, ecall_msg
	jal ra, puts
	j end_handler

handle_ebreak:
	la a0, ebreak_msg
	jal ra, puts
	j end_handler

handle_illegal_insn:
	la a0, illegal_insn_msg
	jal ra, puts
	j end_handler

handle_software_check:
	/* Software-check events should return back to the same instruction
	 * that caused them, rather than one instruction later
	 */
	csrr a0, mepc
	addi a0, a0, -4
	csrw mepc, a0
	/* Disable Zicfilp while we call the stdlib puts function.
	 * This can be removed if/when the standard library is built with landing pads.
	 */
	csrw mseccfg, 0
	la a0, software_check_msg
	jal ra, puts
	csrr t0, mtval
	li t1, 2
	beq t0, t1, swcheck_lp_fault
	li t1, 3
	beq t0, t1, swcheck_ss_fault
	j end_handler
swcheck_lp_fault:
	la a0, software_check_lp_msg
	jal ra, puts
	j end_handler
swcheck_ss_fault:
	la a0, software_check_ss_msg
	jal ra, puts
	j end_handler

handle_unknown:
	la a0, unknown_msg
	jal ra, puts
	j end_handler

end_handler:
	csrr a0, mepc
	addi a0, a0, 4
	csrw mepc, a0
	/* restore all registers, even temporaries! */
	lw ra, 60(sp)
	lw a0, 56(sp)
	lw a1, 52(sp)
	lw a2, 48(sp)
	lw a3, 44(sp)
	lw a4, 40(sp)
	lw a5, 36(sp)
	lw a6, 32(sp)
	lw a7, 28(sp)
	lw t0, 24(sp)
	lw t1, 20(sp)
	lw t2, 16(sp)
	lw t3, 12(sp)
	lw t4, 8(sp)
	lw t5, 4(sp)
	lw t6, 0(sp)
	addi sp, sp, 64
	mret
/* this interrupt can be generated for verification purposes, random or when the PC is equal to a given value*/
verification_irq_handler:
	mret

.section .rodata
software_check_msg:
	.string "software check exception handler entered\n"
software_check_lp_msg:
	.string "    due to landing pad fault\n"
software_check_ss_msg:
	.string "    due to shadow stack fault\n"
illegal_insn_msg:
	.string "illegal instruction exception handler entered\n"
ecall_msg:
	.string "ecall exception handler entered\n"
ebreak_msg:
	.string "ebreak exception handler entered\n"
unknown_msg:
	.string "unknown exception handler entered\n"
no_exception_handler_msg:
	.string "no exception handler installed\n"
