export default function IdiotTrackerPage() {
  return (
    <div className="relative flex h-auto min-h-screen w-full flex-col overflow-x-hidden group/design-root">
      <h3 className="text-slate-900 dark:text-white text-lg font-bold leading-tight tracking-[-0.015em] px-4 pb-2 pt-4">Current Idiot</h3>
      <div className="p-4 @container">
        <div className="flex flex-col items-stretch justify-start rounded-xl @xl:flex-row @xl:items-start shadow-md bg-white dark:bg-[#1C232A] border border-orange-500/30 dark:border-orange-500/50">
          <div className="w-full bg-center bg-no-repeat aspect-[16/10] bg-cover rounded-t-xl @xl:rounded-l-xl @xl:rounded-tr-none @xl:w-48 @xl:aspect-square" style={{ backgroundImage: 'url("https://lh3.googleusercontent.com/aida-public/AB6AXuAlRaBWWQMcg8MF0PruPirc1UCD51rfwIjixAvZ12uHqkMumF1v9uB87klTgUvMmtz8o-bSavRRO69d2NgjY7AFthqWwVupDYl_Mds9DeD2eG0bpaW2-dcBaoKYTVTCizlh_zUXJpfnarHgft4_xN-E4bkkIO1qsCZ2fO35mItbA2UnXU9fV5o_upijZY4cbtrcsza4Xd6JtURA2ZkC3hT5g2Jv2PyqLODqZPIFnOv9QtRg_U1hL3GHwc-mSn-dheYSEYgWIV5JghuI")' }}></div>
          <div className="flex w-full min-w-72 grow flex-col items-stretch justify-center gap-2 p-4">
            <p className="text-orange-500 text-sm font-bold leading-normal">Loser 5 times</p>
            <p className="text-slate-900 dark:text-white text-2xl font-bold leading-tight tracking-[-0.015em]">Alex Johnson</p>
            <div className="flex items-end gap-3 justify-between pt-1">
              <div className="flex flex-col gap-1">
                <p className="text-slate-600 dark:text-slate-400 text-base font-normal leading-normal">Is the Current Idiot</p>
                <p className="text-slate-600 dark:text-slate-400 text-base font-normal leading-normal">Lost on July 23, 2024</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div className="flex justify-stretch">
        <div className="flex flex-1 gap-3 flex-wrap px-4 py-3 justify-between">
          <button className="flex min-w-[84px] max-w-[480px] cursor-pointer items-center justify-center overflow-hidden rounded-lg h-10 px-4 bg-primary/10 text-primary text-sm font-bold leading-normal tracking-[0.015em] flex-1">
            <span className="truncate">View All Players</span>
          </button>
        </div>
      </div>
      <div className="flex items-center justify-between px-4 pb-2 pt-4">
        <h3 className="text-slate-900 dark:text-white text-lg font-bold leading-tight tracking-[-0.015em]">Recent Games</h3>
        <a className="text-primary text-sm font-bold leading-normal" href="#">View All</a>
      </div>
      <div className="flex flex-col gap-3 px-4 pb-28">
        {/* Placeholder Recent Games */}
      </div>
      <div className="fixed bottom-6 right-6 z-20">
        <button className="flex h-16 w-16 cursor-pointer items-center justify-center overflow-hidden rounded-full bg-primary text-white shadow-lg">
          <span className="material-symbols-outlined !text-4xl">add</span>
        </button>
      </div>
    </div>
  );
}
